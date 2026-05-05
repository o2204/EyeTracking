from src.clients.supabase.base_client import SupabaseBaseClient


class SupabaseClient:
    def __init__(self, base: SupabaseBaseClient):
        self.client = base.client
    
    async def upload_pdf(self, file_path: str, file_bytes: bytes):
        try:
            await self.client.storage.from_("reports").upload(
                file_path,
                file_bytes,
                {"content-type": "application/pdf"}
            )

            response = await self.client.storage.from_("reports").create_signed_url(
                file_path,
                300
            )
            return response['signedURL']
        except Exception as e:
            raise RuntimeError(f"Failed to upload PDF to Supabase: {e}")