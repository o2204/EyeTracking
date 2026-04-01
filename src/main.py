from contextlib import asynccontextmanager

from fastapi import FastAPI

from src.routers.user_router import user_router
from src.routers.gaze_control_router import gaze_controller_router
from src.clients.db.database import engine
from src.clients.db.redis import _token_blacklist

@asynccontextmanager
async def lifespan_handler(app: FastAPI):

    print("Server Starting...")

    await _token_blacklist.ping()

    yield

    print("Server shutting down...")

    await engine.dispose()
    await _token_blacklist.close()

app = FastAPI(
    lifespan=lifespan_handler,
)


@app.get('/')
async def get_root():
    return {"message": "Welcome in EyeTracking (v1)"}

app.include_router(user_router)
app.include_router(gaze_controller_router)