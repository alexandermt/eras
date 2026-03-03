from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.models.workspace import WorkspaceStatus


class WorkspaceCreate(BaseModel):
    name: str
    description: Optional[str] = None
    cycle_year: int


class WorkspaceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[WorkspaceStatus] = None


class WorkspaceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: Optional[str]
    cycle_year: int
    status: WorkspaceStatus
    created_by: str
    created_at: datetime
    updated_at: datetime
