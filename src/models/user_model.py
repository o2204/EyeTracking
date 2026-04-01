import uuid
from sqlalchemy import Column, String, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship 

from src.clients.db.database import Base


class UserModel(Base):
    __tablename__= "user"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    name = Column(String, nullable=False)
    
    email = Column(String, unique=True, index=True, nullable=False)
    email_verified = Column(Boolean, default=False)

    password_hash = Column(String, nullable=False) 

    calibration_points = relationship(
        "CalibrationPointsModel",
        back_populates="user",
        cascade="all, delete-orphan"
    )


