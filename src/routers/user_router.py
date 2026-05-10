from typing import Annotated

from fastapi import APIRouter, Depends, Form, Request, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import EmailStr
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from src.schemas.user_schema import UserCreate, GoogleToken
from src.core.cointer import UserServiceDep, get_user_token
from src.schemas.user_schema import UserRead
from src.clients.db.redis import add_jti_to_blacklist
from src.core.config import settings
from src.core.cointer import templates
from src.models.user_model import UserModel
from src.core.utils.password_validator import validate_password

user_router = APIRouter(prefix="/user", tags=["Users"])


@user_router.post(
    "/signup",
    response_model=UserRead
)
async def create_user(
    user: UserCreate,
    user_service: UserServiceDep
):
    errors = validate_password(
        user.password,
        user.confirm_password
    )

    if errors:

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=errors
        )

    return await user_service._add_user(
        data=user.model_dump(
            exclude={"confirm_password"}
        ),
        router_prefix=user_router.prefix
    )


### Login the user 
@user_router.post("/login")
async def login_user(
    request_form: Annotated[OAuth2PasswordRequestForm, Depends()],
    service: UserServiceDep,
):
    token = await service.login(
        request_form.username, 
        request_form.password
    )

    return {
        "access_token": token,
        "token_type": "bearer"
    }


### Verify User Email
@user_router.get("/verify")
async def verify_user_email(token: str, request: Request, service: UserServiceDep):

    is_success = await service.verify_email(token)

    return templates.TemplateResponse(
            request=request,
            name="verify_email_success.html" if is_success else "verify_email_failed.html"
        )


## Forgot Password - Send Reset Link
@user_router.get("/forgot-password")
async def forgot_password(
    email: EmailStr,
    service: UserServiceDep,
):
    await service.send_password_reset_link(email, user_router.prefix)
    return {"detail": "Password reset link sent if the email exists in our system"}


### Password Reset Form
@user_router.get("/reset-password-form")
async def get_reset_password_form(request: Request, token: str):

    return templates.TemplateResponse(
        request=request,
        name="password/reset.html",
        context={
            "request": request,
            "reset_password": f"http://{settings.APP_DOMAIN}{user_router.prefix}/reset-password?token={token}",
            "token": token
        }
    )
    

### Email Password Reset Link
@user_router.post("/reset-password")
async def reset_password(
    request: Request,
    token: Annotated[str, Form()],
    password: Annotated[str, Form()],
    confirm_password: Annotated[str, Form()],
    service: UserServiceDep
):
    errors = validate_password(
        password,
        confirm_password
    )

    if errors:
        return templates.TemplateResponse(
            request=request,
            name="password/reset.html",
            context={
                "request": request,
                "reset_password":
                    f"http://{settings.APP_DOMAIN}"
                    f"{user_router.prefix}"
                    f"/reset-password?token={token}",

                "token": token,
                "errors": errors
            }
        )

    is_success = await service.reset_password(
        token,
        password
    )

    return templates.TemplateResponse(
        request=request,
        name=(
            "password/reset_success.html"
            if is_success
            else "password/reset_failed.html"
        )
    )


### Logout the user 
@user_router.get("/logout")
async def logout_user(
    token_data: Annotated[dict, Depends(get_user_token)],
):
    await add_jti_to_blacklist(token_data["jti"]) 

    return {
        "detail": "Successful Log Out"
    }


@user_router.post("/google-auth")
async def google_auth(
    token_data: GoogleToken,
    service: UserServiceDep
):

    google_user = service.verify_google_token(token_data.id_token)

    email = google_user["email"]
    name = google_user["name"]

    user = await service._get_by_email(email)

    # Signup automatically if user doesn't exist
    if not user:

        user = await service._add(
            UserModel(
                email=email,
                name=name,
                password_hash="google_auth",
            )
        )

    access_token = service.auth.generate_token(user)

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "email": user.email,
            "name": user.name,
        }
    }