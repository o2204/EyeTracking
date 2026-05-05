from typing import List, TYPE_CHECKING
import uuid

from sqlalchemy import String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.clients.db.database import Base

if TYPE_CHECKING:
    from src.models.user_model import UserModel
    from src.models.devices_model import DevicesModel


class DevicesModel(Base):
    __tablename__ = "devices"

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

    name: Mapped[str] = mapped_column(
        String,
        nullable=False
    )

    type: Mapped[str] = mapped_column(
        String,
        nullable=True
    )

    actions: Mapped[List["UserAction"]] = relationship(
        "UserAction",
        back_populates="device",
        cascade="all, delete-orphan"
    )

    user: Mapped["UserModel"] = relationship(
    "UserModel",
    back_populates="devices"
    )