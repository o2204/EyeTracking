import uuid
from sqlalchemy import Column, String, Boolean
from sqlalchemy.dialects.postgresql import UUID

from src.clients.db.database import Base


class AdminModel(Base):
    __tablename__ = "admin"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)

    is_superuser = Column(Boolean, default=False)

    email_verified = Column(Boolean, default=False)
    must_reset_password = Column(Boolean, default=True)
    reset_email_sent = Column(Boolean, default=False)

    password_hash = Column(String, nullable=True)