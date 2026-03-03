from unittest.mock import patch
from tests.conftest import client, setup_db, auth_headers  # noqa: F401

MOCK_APPLICANTS = [
    {
        "applicant_id": "A001",
        "first_name": "Alice",
        "last_name": "Smith",
        "email": "alice@med.edu",
        "program": "Internal Medicine",
        "cycle_year": 2024,
        "status": "Complete",
        "gpa": 3.9,
        "usmle_step1": 240,
        "usmle_step2": 245,
        "medical_school": "State Medical University",
    },
    {
        "applicant_id": "A002",
        "first_name": "Bob",
        "last_name": "Jones",
        "email": "bob@med.edu",
        "program": "Internal Medicine",
        "cycle_year": 2024,
        "status": "Complete",
        "gpa": 3.7,
        "usmle_step1": 230,
        "usmle_step2": 235,
        "medical_school": "National Medical College",
    },
]


def _create_workspace(client, cycle_year=2024):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "Test", "cycle_year": cycle_year},
        headers=auth_headers(roles=["selector"]),
    )
    return resp.json()["id"]


def test_create_snapshot(client):
    ws_id = _create_workspace(client)
    with patch("app.routers.snapshots.oracle_service.get_applicants", return_value=MOCK_APPLICANTS):
        resp = client.post(
            f"/api/workspaces/{ws_id}/snapshots/",
            json={"label": "Week 1", "description": "Initial snapshot"},
            headers=auth_headers(roles=["selector"]),
        )
    assert resp.status_code == 201
    body = resp.json()
    assert body["label"] == "Week 1"
    assert body["workspace_id"] == ws_id


def test_list_and_get_snapshot(client):
    ws_id = _create_workspace(client)
    with patch("app.routers.snapshots.oracle_service.get_applicants", return_value=MOCK_APPLICANTS):
        client.post(
            f"/api/workspaces/{ws_id}/snapshots/",
            json={"label": "Snap A"},
            headers=auth_headers(roles=["selector"]),
        )

    resp = client.get(f"/api/workspaces/{ws_id}/snapshots/", headers=auth_headers())
    assert resp.status_code == 200
    snapshots = resp.json()
    assert len(snapshots) == 1
    snap_id = snapshots[0]["id"]

    resp = client.get(f"/api/workspaces/{ws_id}/snapshots/{snap_id}", headers=auth_headers())
    assert resp.status_code == 200
    body = resp.json()
    assert len(body["applicant_data"]) == 2
