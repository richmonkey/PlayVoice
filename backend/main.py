from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

app = FastAPI(title="Google Sign-In Backend")

# iOS OAuth Client ID — idToken 的 aud 字段必须匹配此值
IOS_CLIENT_ID = "393509542742-m6te6k9o3v44o473j2f9ac1b30qbdfrp.apps.googleusercontent.com"

# 如果同时支持 Android / Web 客户端，把它们的 Client ID 也加进来
ALLOWED_CLIENT_IDS = [IOS_CLIENT_ID]


class TokenRequest(BaseModel):
    id_token: str


class UserInfo(BaseModel):
    google_user_id: str  # Google 用户唯一 ID (sub)
    email: str
    name: str | None = None
    picture: str | None = None
    email_verified: bool


@app.post("/auth/google", response_model=UserInfo)
def verify_google_token(body: TokenRequest):
    """
    接收 iOS 客户端传来的 idToken，向 Google 验证其真实性。
    验证通过后返回用户信息，实际项目中这里应创建/查找用户并返回自己的 session token。
    """
    try:
        payload = id_token.verify_oauth2_token(
            body.id_token,
            google_requests.Request(),
            audience=ALLOWED_CLIENT_IDS,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid idToken: {e}",
        )

    # verify_oauth2_token 已检查：签名、iss、aud、exp
    # 此处可额外做业务校验，例如只允许特定域名邮箱
    if not payload.get("email_verified"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email not verified by Google",
        )

    return UserInfo(
        google_user_id=payload["sub"],
        email=payload["email"],
        name=payload.get("name"),
        picture=payload.get("picture"),
        email_verified=payload["email_verified"],
    )


@app.get("/health")
def health():
    return {"status": "ok"}
