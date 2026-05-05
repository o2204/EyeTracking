from fastapi import APIRouter

from ai.core.cointer import CohereDep
from ai.agents.crew_runner import run_analysis_flow
from shared.analysis_schema import Input

router = APIRouter(
    tags=["AI"]
)


@router.post("/predict")
def predict(
    input: Input,
    cohere_client: CohereDep
):
    return run_analysis_flow(input.data, cohere_client)

from fastapi import WebSocket

@router.websocket("/ws/camera")
async def websocket_camera(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_bytes()
            # Minimal processing logic as requested (just return a mock result for integration)
            # In a real scenario, this would call some AI model
            await websocket.send_json({"status": "success", "message": "Frame processed"})
    except Exception as e:
        print(f"WebSocket error: {e}")
    finally:
        await websocket.close()


    