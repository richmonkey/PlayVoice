import dataclasses
import datetime
import logging

from fastapi import HTTPException, status

from models import db, User, Follow, Block, Report

logger = logging.getLogger("moderation")


@dataclasses.dataclass
class BlockedUserItem:
    user_id: int
    name: str | None
    avatar_url: str | None
    created_at: datetime.datetime


def is_blocked(user_a: int, user_b: int) -> bool:
    return (
        Block.select()
        .where(
            ((Block.blocker == user_a) & (Block.blocked == user_b)) |
            ((Block.blocker == user_b) & (Block.blocked == user_a))
        )
        .exists()
    )


def report_user(reporter_id: int, reported_id: int, reason: str) -> None:
    if reporter_id == reported_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot report yourself")
    if not User.select().where(User.id == reported_id).exists():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    Report.create(reporter=reporter_id, reported=reported_id, reason=reason.strip()[:500])
    logger.warning(
        "MODERATION REPORT: user %s reported user %s — reason: %s. Review and act within 24h.",
        reporter_id, reported_id, reason,
    )


def block_user(blocker_id: int, blocked_id: int, reason: str | None) -> None:
    if blocker_id == blocked_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot block yourself")
    if not User.select().where(User.id == blocked_id).exists():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    with db.atomic():
        Block.get_or_create(blocker=blocker_id, blocked=blocked_id)
        Follow.delete().where(
            ((Follow.follower == blocker_id) & (Follow.followee == blocked_id)) |
            ((Follow.follower == blocked_id) & (Follow.followee == blocker_id))
        ).execute()
        Report.create(
            reporter=blocker_id,
            reported=blocked_id,
            reason=(reason or "Blocked by user").strip()[:500],
        )

    logger.warning(
        "MODERATION BLOCK: user %s blocked user %s — reason: %s. Review and act within 24h.",
        blocker_id, blocked_id, reason,
    )


def unblock_user(blocker_id: int, blocked_id: int) -> None:
    deleted = (
        Block.delete()
        .where(Block.blocker == blocker_id, Block.blocked == blocked_id)
        .execute()
    )
    if deleted == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not blocked")


def list_blocked(blocker_id: int) -> list[BlockedUserItem]:
    rows = (
        Block
        .select(Block, User)
        .join(User, on=(Block.blocked == User.id))
        .where(Block.blocker == blocker_id)
        .order_by(Block.created_at.desc())
    )
    return [
        BlockedUserItem(
            user_id=row.blocked.id,
            name=row.blocked.name,
            avatar_url=row.blocked.avatar_url,
            created_at=row.created_at,
        )
        for row in rows
    ]
