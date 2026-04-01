from datetime import timedelta
from uuid import UUID

from fastapi import BackgroundTasks, HTTPException, status 
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from passlib.context import CryptContext


from src.models.user_model import UserModel
from src.services.utils import decode_url_safe_token, generate_access_token, generate_url_safe_token
from src.core.config import settings
from src.services.notification_service import NotificationService

from src.services.base_service import BaseService

password_context = CryptContext(
    schemes=["bcrypt"], 
    deprecated="auto"
)


class UserService(BaseService):
    def __init__(self, model: UserModel, session: AsyncSession, tasks: BackgroundTasks):
        self.model = model
        self.session = session
        self.notification_service = NotificationService(tasks)
    
    async def _add_user(self, data: dict, router_prefix: str) -> UserModel:

        exiting_user = await self._get_by_email(data["email"])
        if exiting_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email May be registered before"
            )
        
        user = self.model(
            email=data["email"],
            name=data["name"],
            password_hash=password_context.hash(data["password"]),
        )

        # Add user to the database and get refreshed data
        user = await self._add(user)
        # Generate the token with user ID
        token = generate_url_safe_token({
            "id": str(user.id)
        })

        # Send registration email with the token
        await self.notification_service.send_email_with_template(
            recipients=[user.email],
            subject="Welcome to Our Service! Please Verify Your Email",
            context={
                "username": user.name,
                "verification_url": f"http://{settings.APP_DOMAIN}{router_prefix}/verify?token={token}"
            },
            template_name="verify_email.html"
        )
        return user
    
    async def verify_email(self, token: str) -> bool:
        token_data = decode_url_safe_token(token)
        if not token_data:
            return False
        
        user = await self._get(UUID(token_data["id"]))
        if not user:
            return False
        
        user.email_verified = True
        await self._update(user)
        return True
    
    async def _get_by_email(self, email: str) -> UserModel | None:
        return await self.session.scalar(
            select(self.model).where(self.model.email == email)
        )
    
    async def _generate_token(self, email, password) -> str:
        # Validate user credentials
        user = await self._get_by_email(email)

        if not user or not password_context.verify(
            password, 
            user.password_hash,
        ):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Email or password is incorrect"
            )
        
        if not user.email_verified:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email is not verified"
            )
        
        return generate_access_token(
            data={
                "user": {
                    "name": user.name,
                    "id": str(user.id),
                }
            }
        )
    
    async def send_password_reset_link(self, email, router_prefix):
        user = await self._get_by_email(email)

        token = generate_url_safe_token({"id": str(user.id)}, salt="password-reset")

        await self.notification_service.send_email_with_template(
            recipients=[user.email],
            subject="EyeTracking Password Reset Request",
            context={
                "username": user.name,
                "reset_url": f"http://{settings.APP_DOMAIN}{router_prefix}/reset-password-form?token={token}"
            },
            template_name="mail_password_reset.html"
        )
    
    async def reset_password(self, token: str, new_password: str) -> bool:
        token_data = decode_url_safe_token(
            token,
            salt="password-reset",
            expiry=timedelta(hours=24)
        )

        if not token_data:
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired token"
            )

        user = await self._get(UUID(token_data["id"]))

        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )
        
        if len(new_password) < 8:
            raise HTTPException(
                status_code=400,
                detail="Password must be at least 8 characters long"
            )
        
        user.password_hash = password_context.hash(new_password)
        await self._update(user)
        return True