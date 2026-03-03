from tests.conftest import client, setup_db, auth_headers  # noqa: F401


def test_create_and_list_workspaces(client):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "2024 Residency", "cycle_year": 2024},
        headers=auth_headers(roles=["selector"]),
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["name"] == "2024 Residency"
    assert body["cycle_year"] == 2024
    assert body["status"] == "active"
    workspace_id = body["id"]

    # List
    resp = client.get("/api/workspaces/", headers=auth_headers())
    assert resp.status_code == 200
    assert any(w["id"] == workspace_id for w in resp.json())


def test_get_workspace(client):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "Test WS", "cycle_year": 2025},
        headers=auth_headers(roles=["admin"]),
    )
    workspace_id = resp.json()["id"]

    resp = client.get(f"/api/workspaces/{workspace_id}", headers=auth_headers())
    assert resp.status_code == 200
    assert resp.json()["id"] == workspace_id


def test_get_workspace_not_found(client):
    resp = client.get("/api/workspaces/9999", headers=auth_headers())
    assert resp.status_code == 404


def test_update_workspace(client):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "Old Name", "cycle_year": 2024},
        headers=auth_headers(roles=["selector"]),
    )
    workspace_id = resp.json()["id"]

    resp = client.patch(
        f"/api/workspaces/{workspace_id}",
        json={"name": "New Name", "status": "archived"},
        headers=auth_headers(roles=["selector"]),
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["name"] == "New Name"
    assert body["status"] == "archived"


def test_delete_workspace_requires_admin(client):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "To Delete", "cycle_year": 2024},
        headers=auth_headers(roles=["selector"]),
    )
    workspace_id = resp.json()["id"]

    # Selector cannot delete
    resp = client.delete(
        f"/api/workspaces/{workspace_id}",
        headers=auth_headers(roles=["selector"]),
    )
    assert resp.status_code == 403

    # Admin can delete
    resp = client.delete(
        f"/api/workspaces/{workspace_id}",
        headers=auth_headers(roles=["admin"]),
    )
    assert resp.status_code == 204
