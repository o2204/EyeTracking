from supabase import create_async_client, AsyncClient
from core.config import Settings


class SupabaseClient:

    def __init__(self, client: AsyncClient):
        self.client = client

    @classmethod
    async def create(cls, settings: Settings):
        url = settings.SUPABASE_URL
        key = settings.SUPABASE_KEY

        if not url or not key:
            raise RuntimeError("Supabase env vars missing")
        
        try:
            client = await create_async_client(url, key)
            return cls(client)
        
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Supabase client: {e}")