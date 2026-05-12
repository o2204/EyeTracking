from pydantic import BaseModel, EmailStr


class AdminCreate(BaseModel):
    name: str 
    email: EmailStr
    is_superuser: bool = False

class AdminMessage(BaseModel):
    message: str
class AdminLogin(BaseModel):
    email: EmailStr
    password: str

class AdminNotificationRequest(BaseModel):
    user_email: EmailStr
    subject: str
    message: str
    notification_type: str = "email" # "email" or "sms"
