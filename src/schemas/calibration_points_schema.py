from pydantic import BaseModel


class CalibrationPointsCreateBase(BaseModel):
    gaze_x: float
    gaze_y: float
    screen_x: int
    screen_y: int