import datetime
import peewee as pw

from config import DB_PATH


def _utcnow() -> datetime.datetime:
    return datetime.datetime.now(datetime.timezone.utc)


db = pw.SqliteDatabase(DB_PATH)


class _Base(pw.Model):
    class Meta:
        database = db


class User(_Base):
    id = pw.AutoField(primary_key=True)
    google_sub = pw.CharField(unique=True, null=True)
    apple_sub = pw.CharField(unique=True, null=True)
    name = pw.CharField(null=True)
    avatar_url = pw.CharField(null=True)
    email = pw.CharField()
    created_at = pw.DateTimeField(default=_utcnow)
    updated_at = pw.DateTimeField(default=_utcnow)

    class Meta:  # pyright: ignore[reportIncompatibleVariableOverride]
        table_name = "users"


class Channel(_Base):
    owner = pw.ForeignKeyField(User, backref="channel", unique=True)
    channel_name = pw.CharField()
    created_at = pw.DateTimeField(default=_utcnow)
    updated_at = pw.DateTimeField(default=_utcnow)

    class Meta:  # pyright: ignore[reportIncompatibleVariableOverride]
        table_name = "channels"


class Follow(_Base):
    follower = pw.ForeignKeyField(User, backref="following")
    followee = pw.ForeignKeyField(User, backref="followers")
    created_at = pw.DateTimeField(default=_utcnow)

    class Meta:  # pyright: ignore[reportIncompatibleVariableOverride]
        table_name = "follows"
        indexes = (
            (("follower", "followee"), True),
        )
