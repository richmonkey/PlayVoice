import dataclasses

from models import db, User, Channel, Follow, _utcnow


@dataclasses.dataclass
class UserResult:
    id: int
    name: str | None
    email: str
    avatar_url: str | None
    is_new_user: bool


def get_or_create_user(
    google_sub: str,
    email: str,
    name: str | None,
    avatar_url: str | None,
) -> UserResult:
    with db.atomic():
        user, is_new_user = User.get_or_create(
            google_sub=google_sub,
            defaults={"email": email, "name": name, "avatar_url": avatar_url},
        )

        if not is_new_user:
            (User.update(email=email, updated_at=_utcnow())
                 .where(User.id == user.id)
                 .execute())
            user.email = email

        if is_new_user:
            default_name = name or email.split("@")[0]
            Channel.create(owner=user, channel_name=f"{default_name}'s channel")

    return UserResult(
        id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=user.avatar_url,
        is_new_user=is_new_user,
    )


def get_or_create_user_apple(
    apple_sub: str,
    email: str | None,
    name: str | None,
) -> UserResult:
    with db.atomic():
        resolved_email = email or f"{apple_sub}@privaterelay.appleid.com"
        user, is_new_user = User.get_or_create(
            apple_sub=apple_sub,
            defaults={"email": resolved_email, "name": name, "avatar_url": None},
        )

        if not is_new_user:
            (User.update(email=resolved_email, updated_at=_utcnow())
                 .where(User.id == user.id)
                 .execute())
            user.email = resolved_email            

        if is_new_user:
            default_name = name or resolved_email.split("@")[0]
            Channel.create(owner=user, channel_name=f"{default_name}'s channel")

    return UserResult(
        id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=user.avatar_url,
        is_new_user=is_new_user,
    )


@dataclasses.dataclass
class UserSearchItem:
    user_id: int
    name: str | None
    avatar_url: str | None
    channel_name: str | None
    is_followed: bool


def update_name(user_id: int, name: str) -> None:
    (User.update(name=name, updated_at=_utcnow())
         .where(User.id == user_id)
         .execute())


def search_users(keyword: str, current_user_id: int) -> list[UserSearchItem]:
    keyword = keyword.strip()
    if not keyword:
        return []

    followed_ids = {
        f.followee_id
        for f in Follow.select(Follow.followee).where(Follow.follower == current_user_id)
    }

    rows = (
        Channel
        .select(Channel, User)
        .join(User)
        .where(
            (User.id != current_user_id) &
            (User.name.contains(keyword) | Channel.channel_name.contains(keyword))
        )
    )

    return [
        UserSearchItem(
            user_id=row.owner.id,
            name=row.owner.name,
            avatar_url=row.owner.avatar_url,
            channel_name=row.channel_name,
            is_followed=row.owner.id in followed_ids,
        )
        for row in rows
    ]
