from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    name: str
    email: EmailStr

class UserCreate(UserBase):
    password: str
    confirm_password: str

class UserRead(UserBase):
    pass 

class GoogleToken(BaseModel):
    id_token: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str
