from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Optional, Any


class SnapshotCreate(BaseModel):
    label: str
    description: Optional[str] = None


class SnapshotOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    workspace_id: int
    label: str
    description: Optional[str]
    created_by: str
    created_at: datetime


class SnapshotDetail(SnapshotOut):
    applicant_data: list[dict[str, Any]]
