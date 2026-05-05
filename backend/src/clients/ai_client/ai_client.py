import httpx

from src.core.config import settings

class AIClient:
    def __init__(self):
        self.base_url = settings.AI_SERVICE_URL

    
    async def analyze(self, data):
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/predict",
                json={"data": data}
            )


        return response.json()