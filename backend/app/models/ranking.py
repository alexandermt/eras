from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Float, UniqueConstraint
from sqlalchemy.orm import relationship
from app.database.mariadb import Base


class Ranking(Base):
    __tablename__ = "rankings"

    id = Column(Integer, primary_key=True, index=True)
    workspace_id = Column(Integer, ForeignKey("workspaces.id"), nullable=False)
    applicant_id = Column(String(64), nullable=False, index=True)
    rank = Column(Integer, nullable=False)
    score = Column(Float, nullable=True)
    notes = Column(String(2048), nullable=True)
    ranked_by = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    workspace = relationship("Workspace", back_populates="rankings")

    __table_args__ = (
        UniqueConstraint("workspace_id", "applicant_id", name="uq_workspace_applicant"),
    )
