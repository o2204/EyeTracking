import uuid
from typing import List, TYPE_CHECKING

from sqlalchemy import String, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.clients.db.database import Base
if TYPE_CHECKING:
    from src.models.calibration_points_model import CalibrationPointsModel
    from src.models.devices_model import DevicesModel
    from src.models.user_actions_model import UserAction


class UserModel(Base):
    __tablename__ = "users" 

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    name: Mapped[str] = mapped_column(String, nullable=False)

    email: Mapped[str] = mapped_column(
        String,
        unique=True,
        index=True,
        nullable=False
    )

    email_verified: Mapped[bool] = mapped_column(Boolean, default=False)

    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    password_hash: Mapped[str] = mapped_column(String, nullable=False)

    calibration_points: Mapped[List["CalibrationPointsModel"]] = relationship(
        "CalibrationPointsModel",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    actions: Mapped[List["UserAction"]] = relationship(
        "UserAction",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    devices: Mapped[List["DevicesModel"]] = relationship(
    "DevicesModel",
    back_populates="user",
    cascade="all, delete-orphan"
    )