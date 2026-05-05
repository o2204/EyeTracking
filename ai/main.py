from fastapi import FastAPI

from ai.routers.analysis_router import router


app = FastAPI()

@app.get("/")
async def get_root():
    return {
        "message": "Welcome From AI Layer(MicroServices)"
    }

app.include_router(router)