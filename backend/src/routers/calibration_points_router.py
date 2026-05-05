from fastapi import APIRouter

from src.core.cointer import CalibrationPointsServiceDep, UserDep
from src.schemas.calibration_points_schema import CalibrationPointsCreateBase

calibration_points_router = APIRouter(
    prefix="/calibration-points",
    tags=["Calibration Points"]
)


@calibration_points_router.post("/save-points")
async def create_calibration_points(
    data: CalibrationPointsCreateBase,
    user: UserDep,
    calibration_points_service: CalibrationPointsServiceDep
):
    points = await calibration_points_service._create_points(user.id, data)
    return {
        "message": "Calibration points created successfully",
        "points": str(points.id)
    }


@calibration_points_router.get("/get-all-points")
async def get_calibration_points(
    user: UserDep,
    calibration_points_service: CalibrationPointsServiceDep
):
    points = await calibration_points_service._get_user_points_by_id(user.id)
    return points


@calibration_points_router.post("/train-model")
async def train_calibration_model(
    user: UserDep,
    service: CalibrationPointsServiceDep
):
    result = await service.train_model(str(user.id))
    return result