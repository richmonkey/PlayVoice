import dataclasses
import datetime

from fastapi import HTTPException, status

from models import Channel, User, Follow, _utcnow


@dataclasses.dataclass
class ChannelItem:
    channel_id: int
    channel_name: str
    owner_user_id: int
    owner_name: str | None
    owner_avatar_url: str | None
    updated_at: datetime.datetime


def get_followed_channels(user_id: int) -> list[ChannelItem]:
    rows = (
        Channel
        .select(Channel, User)
        .join(User)
        .switch(Channel)
        .join(Follow, on=(Follow.followee == User.id))
        .where(Follow.follower == user_id)
        .order_by(Channel.updated_at.desc())
    )

    return [
        ChannelItem(
            channel_id=row.id,
            channel_name=row.channel_name,
            owner_user_id=row.owner.id,
            owner_name=row.owner.name,
            owner_avatar_url=row.owner.avatar_url,
            updated_at=row.updated_at,
        )
        for row in rows
    ]


def get_my_channel(user_id: int) -> ChannelItem:
    row = (
        Channel
        .select(Channel, User)
        .join(User)
        .where(Channel.owner == user_id)
        .first()
    )
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found")
    return ChannelItem(
        channel_id=row.id,
        channel_name=row.channel_name,
        owner_user_id=row.owner.id,
        owner_name=row.owner.name,
        owner_avatar_url=row.owner.avatar_url,
        updated_at=row.updated_at,
    )


def update_channel_name(user_id: int, channel_name: str) -> ChannelItem:
    channel_name = channel_name.strip()
    if not (2 <= len(channel_name) <= 30):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="频道名称长度须在 2-30 字符之间")

    updated = (
        Channel.update(channel_name=channel_name, updated_at=_utcnow())
        .where(Channel.owner == user_id)
        .execute()
    )
    if updated == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Channel not found")

    return get_my_channel(user_id)
