from fastapi import HTTPException, status

from models import User, Follow
from moderation_service import is_blocked


def follow_user(follower_id: int, followee_id: int) -> None:
    if follower_id == followee_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="不能关注自己")
    if not User.select().where(User.id == followee_id).exists():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")
    if is_blocked(follower_id, followee_id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="无法关注该用户")
    Follow.get_or_create(follower=follower_id, followee=followee_id)


def unfollow_user(follower_id: int, followee_id: int) -> None:
    deleted = (
        Follow.delete()
        .where(Follow.follower == follower_id, Follow.followee == followee_id)
        .execute()
    )
    if deleted == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="未关注该用户")
