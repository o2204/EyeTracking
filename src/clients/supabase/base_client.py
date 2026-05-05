from supabase import create_async_client, AsyncClient

from src.core.config import settings


class SupabaseBaseClient:
    def __init__(self, client: AsyncClient):
        self.client = client
    
    @classmethod
    async def create(cls):
        try:
            client = await create_async_client(
                settings.SUPABASE_URL,
                settings.SUPABASE_KEY
            )
            return cls(client)
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Supabase client: {e}")