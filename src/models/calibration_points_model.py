from datetime import datetime
import uuid
from sqlalchemy import Column, Float, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from src.clients.db.database import Base


class CalibrationPointsModel(Base):
    __tablename__= "calibration_points"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    user_id = Column(
        UUID(as_uuid=True), 
        ForeignKey('user.id'), 
        nullable=False, 
        index=True
    )

    gaze_x = Column(Float, nullable=False)
    gaze_y = Column(Float, nullable=False)

    screen_x = Column(Integer, nullable=False)
    screen_y = Column(Integer, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    user = relationship("UserModel", back_populates="calibration_points")