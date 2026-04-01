from fastapi.templating import Jinja2Templates
from typing_extensions import Annotated

from fastapi import BackgroundTasks, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.constant_manger import TEMPLATE_DIR
from src.core.security import oauth2_scheme
from src.clients.db.database import get_db
from src.services.calibration_points_service import CalibrationPointsService
from src.services.user_service import UserService
from src.services.utils import decode_access_token
from src.services.gaze_controller_service import GazeControllerService
from src.models.user_model import UserModel
from src.clients.db.redis import is_jti_blacklisted

# Asynchronous database session dep annotation
SessionDep = Annotated[AsyncSession, Depends(get_db)]

# Jinja2 Templates
templates = Jinja2Templates(TEMPLATE_DIR)

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
    return UserService(
        model=UserModel,
        session=db,
        tasks=tasks
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


#Gaze Controller 
def get_gaze_controller() -> GazeController:
    return GazeController()

GazeControllerDep = Annotated[
    GazeControllerService,
    Depends(get_gaze_controller)
]

# Calibration Points Service dep
def get_calibration_points_service(db: SessionDep) -> CalibrationPointsService:
    return CalibrationPointsService(session=db)

CalibrationPointsServiceDep = Annotated[
    CalibrationPointsService,
    Depends(get_calibration_points_service)
]
