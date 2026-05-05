from fastapi import HTTPException, status
from passlib.context import CryptContext

from src.services.utils import generate_access_token
from src.core.logger import setup_logger

password_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)


class AuthService:
    def __init__(self):
        self.logger = setup_logger("auth_service")

    def hash_password(self, password: str) -> str:
        return password_context.hash(password)

    def verify_password(self, password: str, hashed: str) -> bool:
        return password_context.verify(password, hashed)

    def validate_credentials(self, entity, password: str):
        if not entity:
            self.logger.warning("No entity found")
            raise HTTPException(401, "Invalid email or password")

        is_valid = self.verify_password(password, entity.password_hash)

        self.logger.info(f"Password valid: {is_valid}")
        self.logger.info(f"Email verified: {entity.email_verified}")

        if not is_valid:
            self.logger.warning("❌ Wrong password")
            raise HTTPException(401, "Invalid email or password")

        if hasattr(entity, "email_verified") and not entity.email_verified:
            self.logger.warning("❌ Email not verified")
            raise HTTPException(401, "Email not verified")

    def generate_token(self, entity) -> str:
        return generate_access_token(
            data={
                "user": {
                    "id": str(entity.id),
                    "name": getattr(entity, "name", "admin"),
                }
            }
        )