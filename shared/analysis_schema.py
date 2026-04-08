from typing import List
from pydantic import BaseModel

from shared.enum import RecommendationStatus


class Recommendation(BaseModel):
    device: str
    action: str
    time: str
    recommendation: str


class RecommendationSchema(BaseModel):
    recommendations: List[Recommendation]  

class RecommendationDecision(BaseModel):
    status: RecommendationStatus

class Input(BaseModel):
    data: list