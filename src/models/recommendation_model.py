import uuid
from datetime import datetime

from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import String, DateTime, Enum

from src.clients.db.database import Base
from shared.enum import RecommendationStatus


class RecommendationModel(Base):
    __tablename__ = "recommendations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4
    )

    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))

    device: Mapped[str] = mapped_column(String)
    action: Mapped[str] = mapped_column(String)
    time: Mapped[str] = mapped_column(String)
    recommendation: Mapped[str] = mapped_column(String)

    status: Mapped[RecommendationStatus] = mapped_column(
        Enum(RecommendationStatus),
        default=RecommendationStatus.PENDING
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow
    )