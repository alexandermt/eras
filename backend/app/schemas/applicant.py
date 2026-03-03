from pydantic import BaseModel, ConfigDict
from typing import Optional


class ApplicantBase(BaseModel):
    applicant_id: str
    first_name: str
    last_name: str
    email: Optional[str] = None
    program: Optional[str] = None
    status: Optional[str] = None
    gpa: Optional[float] = None
    usmle_step1: Optional[int] = None
    usmle_step2: Optional[int] = None


class ApplicantDetail(ApplicantBase):
    model_config = ConfigDict(from_attributes=True)

    date_of_birth: Optional[str] = None
    medical_school: Optional[str] = None
    graduation_year: Optional[int] = None
    research_experience: Optional[str] = None
    personal_statement: Optional[str] = None
    away_rotations: Optional[list[str]] = None
    publications: Optional[int] = None
    alpha_omega_alpha: Optional[bool] = None
    gender: Optional[str] = None
    home_state: Optional[str] = None
