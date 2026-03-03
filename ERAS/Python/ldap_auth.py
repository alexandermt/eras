from ldap3 import Server, Connection, ALL, NTLM
import json


def authenticate(username: str, password: str,
                 host: str, domain: str, base_dn: str) -> str:
    """
    Binds to LDAP with user credentials.
    Returns JSON string with user info on success, empty string '' on failure.
    Called from Delphi via Python4Delphi.
    """
    server = Server(host, get_info=ALL)
    user_dn = f"{domain}\\{username}"
    try:
        conn = Connection(server, user=user_dn, password=password,
                          authentication=NTLM, auto_bind=True)
        conn.search(
            search_base=base_dn,
            search_filter=f"(sAMAccountName={username})",
            attributes=["displayName", "mail", "department", "memberOf"]
        )
        if conn.entries:
            e = conn.entries[0]
            return json.dumps({
                "username":     username,
                "display_name": str(e.displayName),
                "email":        str(e.mail),
                "department":   str(e.department)
            })
    except Exception:
        pass
    return ""
