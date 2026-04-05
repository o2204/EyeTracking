from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from src.services.gaze_controller_service import GazeControllerService
from src.services.ws_auth_service import get_current_user_ws


gaze_controller_router = APIRouter(
    prefix="/controller", 
    tags=["EyeTracking"]
)

@gaze_controller_router.websocket("/gaze-control")
async def gaze_controller(websocket: WebSocket):

    await websocket.accept()
    
    user = await get_current_user_ws(websocket)

    if not user:
        return 
    
    user_id = user["id"]
    
    gaze = GazeControllerService(user_id=user_id)
    
    try:
        await gaze.run(websocket)
    except WebSocketDisconnect:
        print(f"User {user_id} disconnected")