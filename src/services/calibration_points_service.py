import numpy as np
import joblib 
from sklearn.linear_model import LinearRegression

from sqlalchemy import select

from src.models.calibration_points_model import CalibrationPointsModel
from src.clients.db.database import AsyncSession

from src.services.base_service import BaseService

class CalibrationPointsService(BaseService):
    def __init__(self, session: AsyncSession):
        super().__init__(CalibrationPointsModel, session)
    
    async def _create_points(self, user_id, data):
        points = self.model(
            user_id=user_id,
            gaze_x=data.gaze_x,
            gaze_y=data.gaze_y,
            screen_x=data.screen_x,
            screen_y=data.screen_y
        )
        return await self._add(points)
    
    async def _get_user_points_by_id(self, user_id):
        result = await self.session.execute(
            select(self.model).where(self.model.user_id == user_id)
        )
        return result.scalars().all()
    
    async def train_model(self, user_id: str):
        points = await self._get_user_points_by_id(user_id)

        if len(points) < 5:
            raise ValueError("Not enough calibration points")
        
        # Prepare data for training
        X = np.array([p.gaze_x, p.gaze_y] for p in points)

        y_x = np.array([p.screen_x for p in points])
        y_y = np.array([p.screen_y for p in points])

        # Train separate models for x and y coordinates
        model_x = LinearRegression().fit(X, y_x)
        model_y = LinearRegression().fit(X, y_y)

        # Save the models
        joblib.dump(model_x, f'model_x_{user_id}.joblib')
        joblib.dump(model_y, f'model_y_{user_id}.joblib')

        return {
            "message": "Model trained successfully"
        }