from contextlib import asynccontextmanager

from fastapi import FastAPI

from routers.user_router import user_router
from db.database import engine


@asynccontextmanager
async def lifespan_handler(app: FastAPI):
    
    # StartUp
    print("Application Starting...")

    yield

    # Shutdown 
    await engine.dispose()
    print("Application shutting down...")


app = FastAPI(
    lifespan=lifespan_handler,
)


@app.get('/')
async def get_root():
    return {"message": "Welcome in EyeTracking (v1)"}

app.include_router(user_router)