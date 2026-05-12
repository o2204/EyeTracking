from deepface import DeepFace

from google.oauth2 import id_token
from google.auth.transport import requests
import httpx

from datetime import timedelta
from uuid import UUID

from fastapi import BackgroundTasks, HTTPException, status, UploadFile
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.user_model import UserModel
from src.services.utils import decode_url_safe_token, generate_url_safe_token
from src.core.utils.password_validator import validate_password
from src.core.config import settings
from src.services.notification_service import NotificationService

from src.services.base_service import BaseService
from src.services.auth_service import AuthService


class UserService(BaseService):
    def __init__(self, model: UserModel, session: AsyncSession, auth_service: AuthService, tasks: BackgroundTasks):
        self.session = session
        self.model = model
        self.auth = auth_service
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
            password_hash=self.auth.hash_password(data["password"]),
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
    
    async def verify_google_token(self, token: str):
        try:
            idinfo = id_token.verify_oauth2_token(
                token,
                requests.Request(),
                settings.GOOGLE_CLIENT_ID
            )
            return {
                "email": idinfo.get("email"),
                "name": idinfo.get("name", "User"),
            }
        except Exception:
            # Fallback for Flutter Web which often returns access_token instead of id_token
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    "https://www.googleapis.com/oauth2/v3/userinfo",
                    headers={"Authorization": f"Bearer {token}"}
                )
                if resp.status_code == 200:
                    user_info = resp.json()
                    return {
                        "email": user_info.get("email"),
                        "name": user_info.get("name", "User"),
                    }
            raise ValueError("Invalid Google token")

    async def _get_by_email(self, email: str) -> UserModel | None:
        return await self.session.scalar(
            select(self.model).where(self.model.email == email)
        )
    
    async def login(self, email: str, password: str) -> str:
        user = await self._get_by_email(email)
        self.auth.validate_credentials(user, password)

        return self.auth.generate_token(user)


    async def face_login(
        self,
        image: UploadFile,
    ):

        # Create temp directory
        

        if not os.path.exists(temp_dir):
            os.makedirs(temp_dir)

        # Create unique filename
        filename = f"{uuid4()}-{image.filename}"

        # Create temp file path
        temp_path = os.path.join(
            temp_dir,
            filename
        )

        # Save uploaded image temporarily
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(
                image.file,
                buffer
            )

        try:

            # Upload image to Supabase Storage
            bucket_name = "faces"

            with open(temp_path, "rb") as file_data:

                self.supabase.storage.from_(bucket_name).upload(
                    path=filename,
                    file=file_data,
                    file_options={
                        "content-type": image.content_type
                    }
                )

            # Get uploaded image public URL
            uploaded_image_url = (
                self.supabase.storage
                .from_(bucket_name)
                .get_public_url(filename)
            )

            # Get all users with registered face images
            users_result = await self.session.execute(
                select(UserModel).where(
                    UserModel.face_image_url.is_not(None)
                )
            )

            users = users_result.scalars().all()

            # Compare uploaded face against database users
            for user in users:

                try:

                    result = DeepFace.verify(
                        img1_path=temp_path,
                        img2_path=user.face_image_url,
                        enforce_detection=False
                    )

                    # Face matched successfully
                    if result["verified"]:

                        # Generate JWT token
                        token = self.auth.generate_token(user)

                        return {
                            "success": True,
                            "token": token,
                            "uploaded_image_url": uploaded_image_url,
                            "user": {
                                "id": str(user.id),
                                "name": user.name,
                                "email": user.email
                            }
                        }

                except Exception as e:

                    print(
                        f"Face verification failed for "
                        f"{user.email}: {e}"
                    )

                    continue

            # No face matched
            raise HTTPException(
                status_code=401,
                detail="Face not recognized"
            )

        finally:

            # Delete temporary image
            if os.path.exists(temp_path):
                os.remove(temp_path)

    async def send_password_reset_link(self, email, router_prefix):
        user = await self._get_by_email(email)

        if not user:
            return # Don't reveal if the email exists or not

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
        
        user.password_hash = self.auth.hash_password(new_password)
        await self._update(user)
        return True
    
    async def get_users_count(self) -> int:
        result = await self.session.scalar(
            select(func.count()).select_from(self.model)
        )
        return result or 0
    
    async def get_verified_users_count(self) -> int:
        result = await self.session.scalar(
            select(func.count()).select_from(self.model).where(self.model.email_verified.is_(True))
        )
        return result or 0
    async def update_user(self, user_id: UUID, update_data: dict) -> UserModel:
        user = await self._get(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        if "name" in update_data and update_data["name"]:
            user.name = update_data["name"]
        
        if "email" in update_data and update_data["email"]:
            # Check if email is already taken by another user
            existing_user = await self._get_by_email(update_data["email"])
            if existing_user and existing_user.id != user_id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email already registered"
                )
            user.email = update_data["email"]
        
        if "password" in update_data and update_data["password"]:
            user.password_hash = self.auth.hash_password(update_data["password"])
        
        await self._update(user)
        return user
