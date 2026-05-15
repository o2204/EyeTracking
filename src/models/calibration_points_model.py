from datetime import datetime
import uuid

from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import Float, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from src.clients.db.database import Base
from src.models.user_model import UserModel


class CalibrationPointsModel(Base):
    __tablename__ = "calibration_points"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False,
        index=True
    )

    gaze_x: Mapped[float] = mapped_column(Float, nullable=False)
    gaze_y: Mapped[float] = mapped_column(Float, nullable=False)

    screen_x: Mapped[int] = mapped_column(Integer, nullable=False)
    screen_y: Mapped[int] = mapped_column(Integer, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )

    user: Mapped["UserModel"] = relationship(
        "UserModel",
        back_populates="calibration_points"
    )