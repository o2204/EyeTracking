from pydantic_settings import BaseSettings


class Settings(BaseSettings):

    # Database
    DATABASE_URL: str

    REDIS_HOST: str
    REDIS_PORT: str

    # Auth 
    JWT_SECRET: str 
    JWT_ALGORITHM: str 

    # App Settings 
    APP_NAME: str = "EyeTracking"
    APP_DOMAIN: str = "localhost:8000"

    class Config:
        env_file = ".env"
        extra="ignore"


class NotificationSettings(BaseSettings):

    MAIL_USERNAME: str
    MAIL_PASSWORD: str
    MAIL_FROM: str
    MAIL_FROM_NAME: str
    MAIL_SERVER: str
    MAIL_PORT: int
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False
    USE_CREDENTIALS: bool = True
    VALIDATE_CERTS: bool = True

    TWILIO_SID: str 
    TWILIO_AUTH_TOKEN: str
    TWILIO_NUMBER: str

    class Config:
        env_file = ".env"
        extra="ignore"


def get_settings():
    return Settings()
