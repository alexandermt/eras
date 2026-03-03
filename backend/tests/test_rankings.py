from unittest.mock import patch
from tests.conftest import client, setup_db, auth_headers  # noqa: F401

MOCK_APPLICANTS = [
    {
        "applicant_id": "A001",
        "first_name": "Alice",
        "last_name": "Smith",
        "medical_school": "State Medical University",
        "gpa": 3.9,
        "usmle_step1": 240,
        "usmle_step2": 245,
    },
    {
        "applicant_id": "A002",
        "first_name": "Bob",
        "last_name": "Jones",
        "medical_school": "National Medical College",
        "gpa": 3.7,
        "usmle_step1": 230,
        "usmle_step2": 235,
    },
]


def _create_workspace(client):
    resp = client.post(
        "/api/workspaces/",
        json={"name": "Rankings Test", "cycle_year": 2024},
        headers=auth_headers(roles=["selector"]),
    )
    return resp.json()["id"]


def test_upsert_and_list_rankings(client):
    ws_id = _create_workspace(client)
    payload = [
        {"applicant_id": "A001", "rank": 1, "score": 95.0},
        {"applicant_id": "A002", "rank": 2, "score": 88.5},
    ]
    resp = client.put(
        f"/api/workspaces/{ws_id}/rankings/",
        json=payload,
        headers=auth_headers(roles=["selector"]),
    )
    assert resp.status_code == 200
    body = resp.json()
    assert len(body) == 2
    assert body[0]["rank"] == 1
    assert body[0]["applicant_id"] == "A001"

    # List
    resp = client.get(f"/api/workspaces/{ws_id}/rankings/", headers=auth_headers())
    assert resp.status_code == 200
    assert len(resp.json()) == 2


def test_rankings_replace_existing(client):
    ws_id = _create_workspace(client)
    client.put(
        f"/api/workspaces/{ws_id}/rankings/",
        json=[{"applicant_id": "A001", "rank": 1}],
        headers=auth_headers(roles=["selector"]),
    )
    # Replace with different set
    resp = client.put(
        f"/api/workspaces/{ws_id}/rankings/",
        json=[
            {"applicant_id": "A002", "rank": 1},
            {"applicant_id": "A001", "rank": 2},
        ],
        headers=auth_headers(roles=["selector"]),
    )
    assert resp.status_code == 200
    body = resp.json()
    assert len(body) == 2
    assert body[0]["applicant_id"] == "A002"


def test_export_ranked_list(client):
    ws_id = _create_workspace(client)
    client.put(
        f"/api/workspaces/{ws_id}/rankings/",
        json=[
            {"applicant_id": "A001", "rank": 1, "score": 95.0},
            {"applicant_id": "A002", "rank": 2, "score": 88.5},
        ],
        headers=auth_headers(roles=["selector"]),
    )

    with patch(
        "app.routers.export.oracle_service.get_applicants",
        return_value=MOCK_APPLICANTS,
    ):
        resp = client.get(
            f"/api/workspaces/{ws_id}/export/ranked-list",
            headers=auth_headers(),
        )
    assert resp.status_code == 200
    assert "spreadsheetml" in resp.headers["content-type"]
    assert resp.headers["content-disposition"].endswith(".xlsx\"")
    # Verify we got a valid XLSX (starts with PK magic bytes)
    assert resp.content[:2] == b"PK"
