from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
)
from urllib.parse import unquote

from src.core.config import get_settings


settings = get_settings()

class Base(DeclarativeBase):
    pass

# Fix URL-encoded characters in password
database_url = unquote(settings.DATABASE_URL)

engine: AsyncEngine = create_async_engine(
    database_url,
    echo=False,
    pool_pre_ping=True,
    pool_size=10,          # max persistent connections (was default 5)
    max_overflow=20,       # allow bursts up to 30 total
    pool_recycle=1800,     # recycle connections every 30 min to avoid stale ones
    pool_timeout=30,       # wait max 30s for a connection before raising
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()