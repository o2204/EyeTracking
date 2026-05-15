from datetime import datetime, timedelta, timezone
from uuid import uuid4

from fastapi import HTTPException, status
import jwt
from itsdangerous import BadSignature, SignatureExpired, URLSafeTimedSerializer

from src.core.config import settings
from src.core.constant_manger import _DEFAULT_ACCESS_TOKEN_EXPIRY


# Default 15-minute access token — reduced from 24 h.
# Long-lived access tokens are a security risk; use refresh tokens for
# persistent sessions in production.


def generate_access_token(
        data: dict,
        expiry: timedelta = _DEFAULT_ACCESS_TOKEN_EXPIRY,
) -> str:
    payload = {
        **data,
        "jti": str(uuid4()),
        "exp": datetime.now(timezone.utc) + expiry,
    }
    return jwt.encode(
        payload,
        settings.JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict | None:
    try:
        return jwt.decode(
            jwt=token,
            key=settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM],
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
        )
    except jwt.InvalidTokenError:
        # Covers all other JWT errors (bad signature, malformed, etc.)
        return None


def generate_url_safe_token(data: dict, salt: str | None = None) -> str:
    return _serializer.dumps(data, salt=salt)


def decode_url_safe_token(
    token: str,
    salt: str | None = None,
    expiry: timedelta | None = None,
) -> dict | None:
    try:
        return _serializer.loads(
            token,
            salt=salt,
            max_age=int(expiry.total_seconds()) if expiry else None,
        )
    except (BadSignature, SignatureExpired):
        return None