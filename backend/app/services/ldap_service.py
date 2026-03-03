from typing import Optional
from app.config import get_settings

settings = get_settings()


class LDAPAuthError(Exception):
    pass


def _import_ldap():
    """Lazily import the python-ldap package (requires native libs)."""
    try:
        import ldap  # noqa: PLC0415
        import ldap.filter  # noqa: PLC0415
        return ldap
    except ImportError as exc:
        raise LDAPAuthError("LDAP library not available") from exc


def authenticate_user(username: str, password: str) -> dict:
    """
    Authenticate *username* against LDAP and return user info dict.
    Raises LDAPAuthError on failure.
    """
    ldap = _import_ldap()
    import ldap.filter as ldap_filter  # noqa: PLC0415

    try:
        conn = ldap.initialize(settings.ldap_server)
        conn.set_option(ldap.OPT_REFERRALS, 0)
        conn.set_option(ldap.OPT_NETWORK_TIMEOUT, 5)

        # Bind with service account to search for user DN
        conn.simple_bind_s(settings.ldap_bind_dn, settings.ldap_bind_password)

        safe_user = ldap_filter.escape_filter_chars(username)
        search_filter = f"({settings.ldap_user_attr}={safe_user})"
        results = conn.search_s(
            settings.ldap_user_search_base,
            ldap.SCOPE_SUBTREE,
            search_filter,
            ["distinguishedName", "displayName", "mail", "memberOf"],
        )

        if not results:
            raise LDAPAuthError("User not found")

        user_dn, user_attrs = results[0]

        # Bind as the user to verify password
        conn.simple_bind_s(user_dn, password)

        # Resolve roles from group membership
        roles = _resolve_roles(user_attrs.get("memberOf", []))

        display_name = _decode_attr(user_attrs.get("displayName", [username]))
        email = _decode_attr(user_attrs.get("mail", [""]))

        return {
            "username": username,
            "display_name": display_name,
            "email": email,
            "roles": roles,
        }

    except ldap.INVALID_CREDENTIALS:
        raise LDAPAuthError("Invalid credentials")
    except ldap.SERVER_DOWN:
        raise LDAPAuthError("LDAP server unavailable")
    except ldap.LDAPError as exc:
        raise LDAPAuthError(f"LDAP error: {exc}")


def _decode_attr(value: list) -> str:
    if not value:
        return ""
    raw = value[0]
    return raw.decode() if isinstance(raw, bytes) else raw


def _resolve_roles(member_of: list) -> list[str]:
    """Map LDAP group DNs to application roles."""
    roles = []
    group_dns = [g.decode() if isinstance(g, bytes) else g for g in member_of]
    if settings.ldap_admin_group in group_dns:
        roles.append("admin")
    if settings.ldap_selector_group in group_dns:
        roles.append("selector")
    return roles or ["viewer"]
