from fastapi.templating import Jinja2Templates
from typing_extensions import Annotated

from fastapi import BackgroundTasks, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.constant_manger import TEMPLATE_DIR
from src.core.security import oauth2_user_scheme, oauth2_admin_scheme
from src.clients.db.database import get_db
from src.models.admin_model import AdminModel
from src.services.admin_service import AdminService
from src.services.auth_service import AuthService
from src.services.calibration_points_service import CalibrationPointsService
from src.services.connection_manger_service import ConnectionManagerService
from src.services.user_service import UserService
from src.services.utils import decode_access_token
from src.models.user_model import UserModel
from src.clients.db.redis import is_jti_blacklisted

# Asynchronous database session dep annotation
SessionDep = Annotated[AsyncSession, Depends(get_db)]

# Jinja2 Templates
templates = Jinja2Templates(TEMPLATE_DIR)

# Access Tokens for user & admin   
async def validate_token(token: str) -> dict:
    data = decode_access_token(token)

    if data is None or await is_jti_blacklisted(data["jti"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )
    
    return data 

async def get_user_token(token: Annotated[str, Depends(oauth2_user_scheme)]) -> dict:
    return await validate_token(token) 

async def get_admin_token(token: Annotated[str, Depends(oauth2_admin_scheme)]):
    return await validate_token(token)
 
# Logged In User
async def get_current_user(
    token_data: Annotated[dict, Depends(get_user_token)],
    session: SessionDep, 
):
    user = await session.get(UserModel, token_data["user"]["id"])
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User is not found"
        )
    return user

async def get_current_admin(
    token_data: Annotated[dict, Depends(get_admin_token)],
    session: SessionDep
):
    admin = await session.get(AdminModel, token_data["user"]["id"])

    if not admin:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Admin not found"
        )

    return admin

# User service dep
def get_user_service(db: SessionDep, tasks: BackgroundTasks) -> UserService:
    return UserService(
        model=UserModel,
        session=db,
        tasks=tasks,
        auth_service=AuthService()
    )

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


# Calibration Points Service dep
def get_calibration_points_service(db: SessionDep) -> CalibrationPointsService:
    return CalibrationPointsService(session=db)

CalibrationPointsServiceDep = Annotated[
    CalibrationPointsService,
    Depends(get_calibration_points_service)
]


## Connection Manager Service dep
def get_connection_manager_service() -> ConnectionManagerService:
    return ConnectionManagerService()

ConnectionMangerServiceDep = Annotated[
    ConnectionManagerService,
    Depends(get_connection_manager_service)
]


## Admin Service dep
def get_admin_service(
    db: SessionDep,
    tasks: BackgroundTasks
) -> AdminService:
    return AdminService(
        model=AdminModel,
        session=db,
        auth_service=AuthService(),
        tasks=tasks
    )

# Service
AdminServiceDep = Annotated[
    AdminService,
    Depends(get_admin_service)
]

# Current Admin
AdminDep = Annotated[
    AdminModel,
    Depends(get_current_admin)
]