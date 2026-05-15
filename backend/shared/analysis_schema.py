from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel

from shared.enum import RecommendationStatus


class ActionSchema(BaseModel):
    type: str
    value: Optional[int] = None

class RecommendationItem(BaseModel):
    device_id: UUID   
    action: ActionSchema
    time: str
    recommendation: str



class RecommendationSchema(BaseModel):
    recommendations: List[RecommendationItem]  

class RecommendationDecision(BaseModel):
    status: RecommendationStatus

class Input(BaseModel):
    data: list
