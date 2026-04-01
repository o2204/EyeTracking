from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from src.core.cointer import GazeControllerDep


gaze_controller_router = APIRouter(
    prefix="/controller", 
    tags=["EyeTracking"]
)

@gaze_controller_router.websocket("/gaze-control")
async def gaze_controller(
    websocket: WebSocket, 
    gaze_service: GazeControllerDep
):
    
    await websocket.accept()

    user_id = "USER_ID_FROM_TOKEN"
    gaze = GazeControllerDep(user_id=user_id)
    
    try:
        await gaze_service.run(websocket)
    except WebSocketDisconnect:
        print("Client disconnected")