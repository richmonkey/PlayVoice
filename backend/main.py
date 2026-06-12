import time
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import Message

from models import db, User, Channel, Follow
from routers.auth import router as auth_router
from routers.channel import router as channel_router
from routers.user import router as user_router
from routers.follow import router as follow_router

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s  %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("api")


class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        body = await request.body()
        start = time.time()

        # 让后续处理能再次读取 body
        async def receive() -> Message:
            return {"type": "http.request", "body": body, "more_body": False}

        request = Request(request.scope, receive)

        body_str = body.decode("utf-8", errors="replace") if body else ""
        logger.debug(
            "→ %s %s  body=%s",
            request.method,
            request.url.path,
            body_str or "(empty)",
        )

        response = await call_next(request)

        resp_body = b""
        async for chunk in response.body_iterator: # type: ignore
            resp_body += chunk

        elapsed = (time.time() - start) * 1000
        logger.debug(
            "← %d  %.0fms  body=%s",
            response.status_code,
            elapsed,
            resp_body.decode("utf-8", errors="replace"),
        )

        return Response(
            content=resp_body,
            status_code=response.status_code,
            headers=dict(response.headers),
            media_type=response.media_type,
        )


@asynccontextmanager
async def lifespan(app: FastAPI):
    db.connect(reuse_if_open=True)
    db.create_tables([User, Channel, Follow], safe=True)
    yield
    if not db.is_closed():
        db.close()


app = FastAPI(title="Google Sign-In Backend", lifespan=lifespan)

#app.add_middleware(LoggingMiddleware)

app.include_router(auth_router)
app.include_router(channel_router)
app.include_router(user_router)
app.include_router(follow_router)


@app.get("/health")
def health():
    return {"status": "ok"}
