from datetime import datetime, timezone
from sqlalchemy import (
    Column, Integer, String, DateTime, ForeignKey,
    Text, Boolean, JSON, Enum
)
from sqlalchemy.orm import relationship
from app.database.mariadb import Base
import enum


class WorkspaceStatus(str, enum.Enum):
    active = "active"
    archived = "archived"


class Workspace(Base):
    __tablename__ = "workspaces"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    cycle_year = Column(Integer, nullable=False)
    status = Column(Enum(WorkspaceStatus), default=WorkspaceStatus.active, nullable=False)
    created_by = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    snapshots = relationship("Snapshot", back_populates="workspace", cascade="all, delete-orphan")
    rankings = relationship("Ranking", back_populates="workspace", cascade="all, delete-orphan")
