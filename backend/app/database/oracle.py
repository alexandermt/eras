from contextlib import contextmanager
from app.config import get_settings

settings = get_settings()


def _get_connection():
    """Return a read-only Oracle connection."""
    try:
        import cx_Oracle  # noqa: PLC0415
    except ImportError as exc:
        raise RuntimeError("cx_Oracle is not installed") from exc

    conn = cx_Oracle.connect(
        user=settings.oracle_user,
        password=settings.oracle_password,
        dsn=settings.oracle_dsn,
    )
    return conn


@contextmanager
def oracle_cursor():
    """Context manager that yields a cursor and guarantees connection cleanup."""
    conn = _get_connection()
    cursor = conn.cursor()
    try:
        yield cursor
    finally:
        cursor.close()
        conn.close()
