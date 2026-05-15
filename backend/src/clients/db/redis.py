from redis.asyncio import Redis
from src.core.config import settings
from src.core.constant_manger import _BLACKLIST_TTL_SECONDS

# TTL = 24 hours (matches JWT expiry). Without TTL, blacklist grows unboundedly.

_token_blacklist = Redis(
    host=settings.REDIS_HOST,
    port=int(settings.REDIS_PORT),   # cast: env vars are strings
    db=0,
    decode_responses=True,
    socket_connect_timeout=5,        # fail fast if Redis is down
    socket_timeout=5,
)


async def add_jti_to_blacklist(jti: str) -> None:
    """Blacklist a JWT ID. Expires automatically after 24 hours."""
    await _token_blacklist.set(jti, "1", ex=_BLACKLIST_TTL_SECONDS)


async def is_jti_blacklisted(jti: str) -> bool:
    return bool(await _token_blacklist.exists(jti))