import datetime

import logging
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from jose import jwt

from config import ALLOWED_CLIENT_IDS, JWT_SECRET, JWT_ALGORITHM, JWT_EXPIRE_DAYS
from user_service import get_or_create_user
from models import _utcnow

router = APIRouter(prefix="/auth", tags=["auth"])


class TokenRequest(BaseModel):
    id_token: str
    name: str | None = None
    avatar_url: str | None = None


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    is_new_user: bool
    user_id: int
    name: str | None
    email: str
    avatar_url: str | None


def _make_jwt(user_id: int) -> str:
    expire = _utcnow() + datetime.timedelta(days=JWT_EXPIRE_DAYS)
    return jwt.encode({"sub": str(user_id), "exp": expire}, JWT_SECRET, algorithm=JWT_ALGORITHM)


@router.post("/google", response_model=AuthResponse)
def google_auth(body: TokenRequest):
    try:
        payload = id_token.verify_oauth2_token(
            body.id_token,
            google_requests.Request(),
            audience=ALLOWED_CLIENT_IDS,
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Invalid idToken: {e}")

    if not payload.get("email_verified"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Email not verified by Google")
    
    logging.info("google auth success, payload: %s", payload)
    user = get_or_create_user(
        google_sub=payload["sub"],
        email=payload["email"],
        name=payload.get("name") or body.name,
        avatar_url=payload.get("picture") or body.avatar_url,
    )

    return AuthResponse(
        access_token=_make_jwt(user.id),
        is_new_user=user.is_new_user,
        user_id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=user.avatar_url,
    )
