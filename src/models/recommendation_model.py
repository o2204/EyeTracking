import uuid
from datetime import datetime

from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import ForeignKey, String, DateTime, Enum

from src.clients.db.database import Base
from shared.enum import RecommendationStatus


class RecommendationModel(Base):
    __tablename__ = "recommendations"

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

    action_type: Mapped[str] = mapped_column(String, nullable=False)
    action_value: Mapped[int] = mapped_column(nullable=True)
    time: Mapped[str] = mapped_column(String, nullable=True)
    
    recommendation: Mapped[str] = mapped_column(String, nullable=False)

    status: Mapped[RecommendationStatus] = mapped_column(
        Enum(RecommendationStatus, name="recommendation_status"),
        default=RecommendationStatus.PENDING
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )

    report_url: Mapped[str] = mapped_column(String, nullable=True)

    device = relationship("DevicesModel", back_populates="recommendations")
    user = relationship("UserModel", back_populates="recommendations")