from fastapi import APIRouter

from ai.core.cointer import CohereDep
from ai.agents.crew_runner import run_analysis_flow
from shared.analysis_schema import Input

router = APIRouter(
    prefix="/ai",
    tags=["AI"]
)

@router.post("/analyze")
def analyze(
    input: Input,
    cohere_client: CohereDep
):
    return run_analysis_flow(input.data, cohere_client)
    