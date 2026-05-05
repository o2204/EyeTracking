from datetime import datetime
from typing import Optional

from pydantic import BaseModel
from uuid import UUID

from src.core.constant_manger import ActionTypeEnum


class UserActionCreate(BaseModel):
    device_id: UUID
    action: ActionTypeEnum
    value: Optional[str] = None


class UserActionResponse(BaseModel):
    id: UUID
    user_id: UUID
    device_id: UUID
    action: ActionTypeEnum
    value: Optional[str]
    timestamp: datetime
    
    class Config:
        from_attributes = True  ## Change any object to json 
    
