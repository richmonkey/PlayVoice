from fastapi import APIRouter, Depends
from pydantic import BaseModel

from deps import get_current_user_id
from user_service import search_users

router = APIRouter(prefix="/users", tags=["users"])


class UserSearchResponse(BaseModel):
    user_id: int
    name: str | None
    avatar_url: str | None
    channel_name: str | None
    is_followed: bool


@router.get("/search", response_model=list[UserSearchResponse])
def search(q: str, user_id: int = Depends(get_current_user_id)):
    return search_users(q, user_id)
