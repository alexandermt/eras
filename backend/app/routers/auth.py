from fastapi import APIRouter, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import Depends
from app.schemas.auth import TokenResponse
from app.services.ldap_service import authenticate_user, LDAPAuthError
from app.middleware.auth import create_access_token

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/token", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """Authenticate via LDAP and return a JWT access token."""
    try:
        user_info = authenticate_user(form_data.username, form_data.password)
    except LDAPAuthError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token(
        data={"sub": user_info["username"], "roles": user_info["roles"]}
    )
    return TokenResponse(
        access_token=token,
        username=user_info["username"],
        display_name=user_info["display_name"],
        roles=user_info["roles"],
    )
