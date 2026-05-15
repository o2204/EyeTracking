from fastapi import FastAPI

from ai.routers.analysis_router import router


from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def get_root():
    return {
        "message": "Welcome From AI Layer(MicroServices)"
    }

app.include_router(router)