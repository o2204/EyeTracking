from contextlib import asynccontextmanager
import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from src.routers.user_router import user_router
from src.routers.gaze_control_router import gaze_controller_router
from src.routers.admin_router import admin_router
from src.routers.analysis_router import analysis_router

from src.clients.db.database import engine
from src.clients.db.redis import _token_blacklist

from paho.mqtt import publish
from src.core.config import settings

@asynccontextmanager
async def lifespan_handler(app: FastAPI):
    print("Server Starting...")
    await _token_blacklist.ping()
    yield
    print("Server shutting down...")
    await engine.dispose()
    await _token_blacklist.close()


app = FastAPI(lifespan=lifespan_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── API routes (must come BEFORE static mount) ──────────────────────────────
app.include_router(user_router)
app.include_router(gaze_controller_router)
app.include_router(admin_router)
app.include_router(analysis_router)

# ── Serve Flutter web build on "/" (must come LAST) ─────────────────────────
flutter_web_dir = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
    "ui", "build", "web",
)

if os.path.exists(flutter_web_dir):
    app.mount("/", StaticFiles(directory=flutter_web_dir, html=True), name="flutter_web")
else:
    @app.get("/")
    async def get_root():
        return {"message": "Welcome in EyeTracking (v1). Flutter build not found."}

@app.post("/fan/on")
def fan_on():

    publish.single(
        "home/fan",
        "ON",
        hostname=settings.MQTT_BROKER
    )

    return {"status":"ON"}