from datetime import timedelta
from uuid import UUID
import secrets

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from fastapi import HTTPException, status, BackgroundTasks

from src.models.admin_model import AdminModel
from src.models.user_model import UserModel
from src.services.base_service import BaseService
from src.services.auth_service import AuthService
from src.services.utils import decode_url_safe_token, generate_url_safe_token
from src.services.notification_service import NotificationService
from src.core.config import settings
from src.core.logger import setup_logger


class AdminService(BaseService):
    def __init__(
        self,
        model: AdminModel,
        auth_service: AuthService,
        session: AsyncSession,
        tasks: BackgroundTasks
    ):
        self.model = model
        self.session = session
        self.auth = auth_service
        self.notification_service = NotificationService(tasks)
        self.logger = setup_logger("admin_service")

    async def _get_by_email(self, email: str):
        return await self.session.scalar(
            select(self.model).where(self.model.email == email)
        )

    async def create_admin(self, data):
        self.logger.info(f"Creating admin: {data.email}")

        existing = await self._get_by_email(data.email)
        if existing:
            raise HTTPException(400, "Email already exists")

        admin = self.model(
            email=data.email,
            name=data.name,
            password_hash=None,
            is_superuser=data.is_superuser,
            email_verified=True,
            must_reset_password=True
        )

        admin = await self._add(admin)

        token = generate_url_safe_token(
            {"id": str(admin.id)},
            salt="password-reset"
        )

        reset_url = f"http://{settings.APP_DOMAIN}/admin/reset-password-form?token={token}"

        try:
            await self.notification_service.send_email_with_template(
                recipients=[admin.email],
                subject="Set your password",
                context={
                    "username": admin.name,
                    "reset_url": reset_url
                },
                template_name="mail_password_reset.html"
            )
        except Exception as e:
            self.logger.error(f"Email failed: {e}")

        return admin

    async def admin_login(self, email: str, password: str, is_persistent: bool = False):
        self.logger.info(f"Login attempt: {email} (Persistent: {is_persistent})")

        admin = await self._get_by_email(email)

        if not admin:
            raise HTTPException(401, "Invalid email or password")

        if not admin.password_hash:
            raise HTTPException(
                status_code=403,
                detail="Please set your password first"
            )

        self.auth.validate_credentials(admin, password)

        if admin.must_reset_password:
            raise HTTPException(
                status_code=403,
                detail="You must reset your password before login"
            )

        self.logger.info(f"Login success: {email}")

        expiry = timedelta(days=90) if is_persistent else None
        return self.auth.generate_token(admin, expiry=expiry)


    async def reset_admin_password(self, token: str, new_password: str):
        token_data = decode_url_safe_token(
            token,
            salt="password-reset",
            expiry=timedelta(hours=24)
        )

        if not token_data:
            return "expired"

        admin = await self._get(UUID(token_data["id"]))

        if not admin:
            return "not_found"

        admin.password_hash = self.auth.hash_password(new_password)
        admin.must_reset_password = False

        await self._update(admin)

        self.logger.info(f"Password reset success: {admin.email}")

        return "success"
    
    async def send_password_reset_link(self, email, router_prefix):
        admin = await self._get_by_email(email)

        if not admin:
            return # Don't reveal if the email exists or not

        token = generate_url_safe_token({"id": str(admin.id)}, salt="password-reset")

        await self.notification_service.send_email_with_template(
            recipients=[admin.email],
            subject="EyeTracking Password Reset Request",
            context={
                "username": admin.name,
                "reset_url": f"http://{settings.APP_DOMAIN}{router_prefix}/reset-password-form?token={token}"
            },
            template_name="mail_password_reset.html"
        )

    async def delete_admin(self, admin_id: str, current_admin):
        try:
            admin_uuid = UUID(admin_id)
        except ValueError:
            raise HTTPException(400, "Invalid admin ID")

        admin = await self._get(admin_uuid)

        if not admin:
            raise HTTPException(404, "Admin not found")

        if not current_admin.is_superuser:
            raise HTTPException(403, "Only superadmin allowed")

        if admin.id == current_admin.id:
            raise HTTPException(400, "You cannot delete yourself")

        await self._delete(admin)

        return True

    async def send_user_notification(self, data):
        """Send a notification (email or SMS) to a user."""
        self.logger.info(f"Sending {data.notification_type} notification to {data.user_email}")
        
        # Verify user exists in the database
        user = await self.session.scalar(
            select(UserModel).where(UserModel.email == data.user_email)
        )
        if not user:
            raise HTTPException(404, detail="User with this email not found")

        if data.notification_type == "email":
            await self.notification_service.send_email(
                recipients=[data.user_email],
                subject=data.subject,
                body=data.message
            )
        elif data.notification_type == "sms":
            # Assuming user_email is actually a phone number for SMS in this context, 
            # or we fetch the phone number from the user profile.
            # For now, we'll just try to send it.
            await self.notification_service.send_sms(
                to=data.user_email, # User should probably provide phone number here if type is sms
                body=data.message
            )
        else:
            raise HTTPException(400, "Invalid notification type")
        
        return True