import dataclasses

from models import db, User, Channel, _utcnow


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
            (User.update(name=name, avatar_url=avatar_url, updated_at=_utcnow())
                 .where(User.id == user.id)
                 .execute())
            user.name = name
            user.avatar_url = avatar_url

        if is_new_user:
            default_name = name or email.split("@")[0]
            Channel.create(owner=user, channel_name=f"{default_name}的频道")

    return UserResult(
        id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=user.avatar_url,
        is_new_user=is_new_user,
    )
