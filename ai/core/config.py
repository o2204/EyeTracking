from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings

BASE_DIR = Path(__file__).resolve().parent.parent  # ai/


class Settings(BaseSettings):
    # Cohere API
    COHERE_API: str

    class Config:
        env_file=BASE_DIR/ ".env"
        env_file_encoding="utf-8"
        extra="ignore"

@lru_cache
def get_settings():
    return Settings()

settings = get_settings()