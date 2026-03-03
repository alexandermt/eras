from pydantic import BaseModel


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    username: str
    display_name: str
    roles: list[str]


class TokenData(BaseModel):
    username: str
    roles: list[str] = []
