import datetime

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from deps import get_current_user_id
from channel_service import get_followed_channels, get_my_channel, update_channel_name

router = APIRouter(prefix="/channels", tags=["channels"])


class ChannelResponse(BaseModel):
    channel_id: int
    channel_name: str
    owner_user_id: int
    owner_name: str | None
    owner_avatar_url: str | None
    updated_at: datetime.datetime


class UpdateChannelNameRequest(BaseModel):
    channel_name: str


@router.get("/followed", response_model=list[ChannelResponse])
def followed_channels(user_id: int = Depends(get_current_user_id)):
    return get_followed_channels(user_id)


@router.get("/me", response_model=ChannelResponse)
def my_channel(user_id: int = Depends(get_current_user_id)):
    return get_my_channel(user_id)


@router.patch("/me/name", response_model=ChannelResponse)
def rename_channel(body: UpdateChannelNameRequest, user_id: int = Depends(get_current_user_id)):
    return update_channel_name(user_id, body.channel_name)
