from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.database.mariadb import get_db
from app.models.workspace import Workspace
from app.models.audit import AuditLog
from app.schemas.workspace import WorkspaceCreate, WorkspaceUpdate, WorkspaceOut
from app.middleware.auth import get_current_user, require_role
from app.schemas.auth import TokenData

router = APIRouter(prefix="/api/workspaces", tags=["workspaces"])


@router.get("/", response_model=list[WorkspaceOut])
def list_workspaces(
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    return db.query(Workspace).order_by(Workspace.created_at.desc()).all()


@router.post("/", response_model=WorkspaceOut, status_code=status.HTTP_201_CREATED)
def create_workspace(
    payload: WorkspaceCreate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin", "selector")),
):
    workspace = Workspace(
        name=payload.name,
        description=payload.description,
        cycle_year=payload.cycle_year,
        created_by=current_user.username,
    )
    db.add(workspace)
    db.flush()
    db.add(AuditLog(
        username=current_user.username,
        action="create",
        resource_type="workspace",
        resource_id=str(workspace.id),
        ip_address=request.client.host if request.client else None,
    ))
    db.commit()
    db.refresh(workspace)
    return workspace


@router.get("/{workspace_id}", response_model=WorkspaceOut)
def get_workspace(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(get_current_user),
):
    workspace = db.get(Workspace, workspace_id)
    if not workspace:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")
    return workspace


@router.patch("/{workspace_id}", response_model=WorkspaceOut)
def update_workspace(
    workspace_id: int,
    payload: WorkspaceUpdate,
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin", "selector")),
):
    workspace = db.get(Workspace, workspace_id)
    if not workspace:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(workspace, field, value)
    workspace.updated_at = datetime.now(timezone.utc)
    db.add(AuditLog(
        username=current_user.username,
        action="update",
        resource_type="workspace",
        resource_id=str(workspace_id),
        ip_address=request.client.host if request.client else None,
    ))
    db.commit()
    db.refresh(workspace)
    return workspace


@router.delete("/{workspace_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_workspace(
    workspace_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: TokenData = Depends(require_role("admin")),
):
    workspace = db.get(Workspace, workspace_id)
    if not workspace:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workspace not found")
    db.add(AuditLog(
        username=current_user.username,
        action="delete",
        resource_type="workspace",
        resource_id=str(workspace_id),
        ip_address=request.client.host if request.client else None,
    ))
    db.delete(workspace)
    db.commit()

