from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import get_settings
from app.routers import auth, applicants, workspaces, snapshots, rankings, export

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(applicants.router)
app.include_router(workspaces.router)
app.include_router(snapshots.router)
app.include_router(rankings.router)
app.include_router(export.router)


@app.get("/api/health", tags=["health"])
def health_check():
    return {"status": "ok", "version": settings.app_version}
