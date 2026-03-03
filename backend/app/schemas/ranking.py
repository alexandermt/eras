from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Optional


class RankingUpsert(BaseModel):
    applicant_id: str
    rank: int
    score: Optional[float] = None
    notes: Optional[str] = None


class RankingOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    workspace_id: int
    applicant_id: str
    rank: int
    score: Optional[float]
    notes: Optional[str]
    ranked_by: str
    updated_at: datetime
