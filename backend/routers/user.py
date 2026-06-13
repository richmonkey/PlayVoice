from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, field_validator

from deps import get_current_user_id
from user_service import search_users, update_name

router = APIRouter(prefix="/users", tags=["users"])


class UserSearchResponse(BaseModel):
    user_id: int
    name: str | None
    avatar_url: str | None
    channel_name: str | None
    is_followed: bool


class UpdateNameRequest(BaseModel):
    name: str

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        v = v.strip()
        if len(v) < 2 or len(v) > 30:
            raise ValueError("name must be 2–30 characters")
        return v


@router.patch("/me/name", status_code=204)
def update_display_name(
    body: UpdateNameRequest,
    user_id: int = Depends(get_current_user_id),
):
    update_name(user_id, body.name)


@router.get("/search", response_model=list[UserSearchResponse])
def search(q: str, user_id: int = Depends(get_current_user_id)):
    return search_users(q, user_id)
