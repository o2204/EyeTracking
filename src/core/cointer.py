from typing_extensions import Annotated

from fastapi import BackgroundTasks, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from core.security import oauth2_scheme
from src.db.database import get_db
from services.user_service import UserService
from services.utils import decode_access_token
from models.user_model import UserModel
from db.redis import is_jti_blacklisted

# Asynchronous database session dep annotation
SessionDep = Annotated[AsyncSession, Depends(get_db)]


# Access Token data dep
async def get_access_token(token: Annotated[str, Depends(oauth2_scheme)]) -> dict:
    data = decode_access_token(token)

    if data is None or await is_jti_blacklisted(data["jti"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token"
        ) 
    return data 


# Logged In User
async def get_current_user(
    token_data: Annotated[dict, Depends(get_access_token)],
    session: SessionDep, 
):
    return await session.get(UserModel, token_data["user"]["id"])


# User service dep
def get_user_service(db: SessionDep, tasks: BackgroundTasks) -> UserService:
    return UserService(db, tasks)


# User dep
UserDep = Annotated[
    UserModel,
    Depends(get_current_user)
]

# User Service dep
UserServiceDep = Annotated[
    UserService,
    Depends(get_user_service)
]
