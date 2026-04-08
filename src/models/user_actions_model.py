from datetime import datetime
import uuid
from typing import TYPE_CHECKING

from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import DateTime, String, ForeignKey, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID

from src.clients.db.database import Base
from src.core.constant_manger import ActionTypeEnum
from src.models.devices_model import DevicesModel

if TYPE_CHECKING:
    from src.models.user_model import UserModel


class UserAction(Base):
    __tablename__ = "user_actions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    device_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("devices.id"),
        nullable=False
    )

    action: Mapped[ActionTypeEnum] = mapped_column(
        SQLEnum(ActionTypeEnum),
        nullable=False
    )

    value: Mapped[str] = mapped_column(String, nullable=True)

    timestamp: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        index=True
    )

    user: Mapped["UserModel"] = relationship(
        "UserModel",
        back_populates="actions"
    )

    device: Mapped[DevicesModel] = relationship(
        "DevicesModel",
        back_populates="actions"
    )