from fastapi import APIRouter, Depends, status

from deps import get_current_user_id
from follow_service import follow_user, unfollow_user

router = APIRouter(prefix="/follows", tags=["follows"])


@router.post("/{followee_id}", status_code=status.HTTP_204_NO_CONTENT)
def follow(followee_id: int, user_id: int = Depends(get_current_user_id)):
    follow_user(user_id, followee_id)


@router.delete("/{followee_id}", status_code=status.HTTP_204_NO_CONTENT)
def unfollow(followee_id: int, user_id: int = Depends(get_current_user_id)):
    unfollow_user(user_id, followee_id)
