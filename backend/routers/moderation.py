import datetime

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, field_validator

from deps import get_current_user_id
from moderation_service import report_user, block_user, unblock_user, list_blocked

router = APIRouter(tags=["moderation"])


class ReportRequest(BaseModel):
    reported_user_id: int
    reason: str

    @field_validator("reason")
    @classmethod
    def validate_reason(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("reason is required")
        return v


class BlockRequest(BaseModel):
    reason: str | None = None


class BlockedUserResponse(BaseModel):
    user_id: int
    name: str | None
    avatar_url: str | None
    created_at: datetime.datetime


@router.post("/reports", status_code=status.HTTP_204_NO_CONTENT)
def create_report(body: ReportRequest, user_id: int = Depends(get_current_user_id)):
    report_user(user_id, body.reported_user_id, body.reason)


@router.post("/blocks/{blocked_user_id}", status_code=status.HTTP_204_NO_CONTENT)
def create_block(blocked_user_id: int, body: BlockRequest, user_id: int = Depends(get_current_user_id)):
    block_user(user_id, blocked_user_id, body.reason)


@router.delete("/blocks/{blocked_user_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_block(blocked_user_id: int, user_id: int = Depends(get_current_user_id)):
    unblock_user(user_id, blocked_user_id)


@router.get("/blocks", response_model=list[BlockedUserResponse])
def get_blocks(user_id: int = Depends(get_current_user_id)):
    return list_blocked(user_id)
