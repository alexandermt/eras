from fastapi import APIRouter, HTTPException, status, Query, Depends
from app.schemas.applicant import ApplicantBase, ApplicantDetail
from app.services import oracle_service
from app.middleware.auth import get_current_user
from app.schemas.auth import TokenData
from typing import Optional

router = APIRouter(prefix="/api/applicants", tags=["applicants"])


@router.get("/", response_model=list[ApplicantBase])
def list_applicants(
    program: Optional[str] = Query(None),
    cycle_year: Optional[int] = Query(None),
    current_user: TokenData = Depends(get_current_user),
):
    """List applicants from Oracle ITS (read-only)."""
    return oracle_service.get_applicants(program=program, cycle_year=cycle_year)


@router.get("/{applicant_id}", response_model=ApplicantDetail)
def get_applicant(
    applicant_id: str,
    current_user: TokenData = Depends(get_current_user),
):
    """Get detailed applicant record from Oracle ITS."""
    applicant = oracle_service.get_applicant(applicant_id)
    if not applicant:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Applicant not found")
    return applicant
