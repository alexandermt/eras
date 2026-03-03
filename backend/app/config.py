from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Application
    app_name: str = "ERAS API"
    app_version: str = "1.0.0"
    debug: bool = False
    secret_key: str = "changeme-use-a-strong-random-key-in-production"
    access_token_expire_minutes: int = 480  # 8 hours

    # MariaDB
    mariadb_host: str = "localhost"
    mariadb_port: int = 3306
    mariadb_user: str = "eras"
    mariadb_password: str = "eras_password"
    mariadb_db: str = "eras"

    # Oracle (read-only)
    oracle_dsn: str = "localhost:1521/ORCL"
    oracle_user: str = "eras_readonly"
    oracle_password: str = "oracle_password"

    # LDAP
    ldap_server: str = "ldap://localhost:389"
    ldap_base_dn: str = "dc=example,dc=com"
    ldap_bind_dn: str = "cn=eras-svc,dc=example,dc=com"
    ldap_bind_password: str = "ldap_service_password"
    ldap_user_search_base: str = "ou=users,dc=example,dc=com"
    ldap_user_attr: str = "sAMAccountName"
    ldap_group_search_base: str = "ou=groups,dc=example,dc=com"
    ldap_selector_group: str = "cn=eras-selectors,ou=groups,dc=example,dc=com"
    ldap_admin_group: str = "cn=eras-admins,ou=groups,dc=example,dc=com"

    # CORS
    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:5173"]

    @property
    def mariadb_url(self) -> str:
        return (
            f"mysql+pymysql://{self.mariadb_user}:{self.mariadb_password}"
            f"@{self.mariadb_host}:{self.mariadb_port}/{self.mariadb_db}"
        )

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
