from fastapi import WebSocket

from src.services.utils import decode_access_token
from src.clients.db.redis import is_jti_blacklisted


async def get_current_user_ws(websocket: WebSocket):
    token = websocket.query_params.get("token")

    if not token:
        await websocket.close(code=1008)
        return None

    data = decode_access_token(token)

    if not data or await is_jti_blacklisted(data["jti"]):
        await websocket.close(code=1008)
        return None

    return data["user"]