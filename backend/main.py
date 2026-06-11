from contextlib import asynccontextmanager

from fastapi import FastAPI

from models import db, User, Channel, Follow
from routers.auth import router as auth_router
from routers.channel import router as channel_router
from routers.user import router as user_router
from routers.follow import router as follow_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    db.connect(reuse_if_open=True)
    db.create_tables([User, Channel, Follow], safe=True)
    yield
    if not db.is_closed():
        db.close()


app = FastAPI(title="Google Sign-In Backend", lifespan=lifespan)

app.include_router(auth_router)
app.include_router(channel_router)
app.include_router(user_router)
app.include_router(follow_router)


@app.get("/health")
def health():
    return {"status": "ok"}
