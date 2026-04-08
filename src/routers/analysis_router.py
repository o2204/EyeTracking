from uuid import UUID

from fastapi import APIRouter

from src.core.cointer import AnalysisServiceDep, UserDep
from shared.analysis_schema import RecommendationDecision

analysis_router = APIRouter(
    prefix="/analysis",
    tags=["Analysis Agent"]
)


@analysis_router.get("/")
async def analyze_user(
    service: AnalysisServiceDep,
    current_user: UserDep
):
    return await service.analyze_user(current_user.id)


@analysis_router.post("/recommendation_id/{recommendation_id}/decision")
async def make_decision(
    recommendation_id: UUID,
    decision: RecommendationDecision,
    service: AnalysisServiceDep,
    current_user: UserDep
):
    return await service.make_decision(
        current_user.id,
        recommendation_id,
        decision
    )