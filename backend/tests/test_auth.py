from unittest.mock import patch
from tests.conftest import client, setup_db, auth_headers  # noqa: F401


def test_login_success(client):
    mock_user = {
        "username": "jdoe",
        "display_name": "John Doe",
        "email": "jdoe@example.com",
        "roles": ["selector"],
    }
    with patch("app.routers.auth.authenticate_user", return_value=mock_user):
        resp = client.post(
            "/api/auth/token",
            data={"username": "jdoe", "password": "secret"},
        )
    assert resp.status_code == 200
    body = resp.json()
    assert body["username"] == "jdoe"
    assert body["token_type"] == "bearer"
    assert "access_token" in body
    assert "selector" in body["roles"]


def test_login_invalid_credentials(client):
    from app.services.ldap_service import LDAPAuthError

    with patch("app.routers.auth.authenticate_user", side_effect=LDAPAuthError("Invalid credentials")):
        resp = client.post(
            "/api/auth/token",
            data={"username": "jdoe", "password": "wrong"},
        )
    assert resp.status_code == 401


def test_protected_route_no_token(client):
    resp = client.get("/api/workspaces/")
    assert resp.status_code == 401


def test_protected_route_bad_token(client):
    resp = client.get(
        "/api/workspaces/",
        headers={"Authorization": "Bearer bad.token.here"},
    )
    assert resp.status_code == 401
