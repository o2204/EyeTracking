import uuid
from typing import List, Optional
from pydantic import BaseModel

class DeviceBase(BaseModel):
    name: str
    type: Optional[str] = None
    status: Optional[str] = "Connected"
    accessibility_features: List[str] = []

class DeviceCreate(DeviceBase):
    pass

class DeviceUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    status: Optional[str] = None
    accessibility_features: Optional[List[str]] = None

class DeviceResponse(DeviceBase):
    id: uuid.UUID
    user_id: uuid.UUID

    class Config:
        from_attributes = True
