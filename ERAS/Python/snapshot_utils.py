"""
snapshot_utils.py
Utility functions for transforming Oracle applicant data
into the ERAS snapshot JSON format stored in snapshot_applicants.applicant_data.
"""


def normalise_applicant(row: dict) -> dict:
    """
    Standardise field names from Oracle ITS applicant rows into the
    canonical ERAS snapshot format.

    :param row: dict with raw Oracle column names (lower-cased)
    :return:    dict with standardised keys used throughout ERAS
    """
    return {
        "applicant_id":        str(row.get("applicant_id", "")),
        "forename":            str(row.get("forename", "")),
        "surname":             str(row.get("surname", "")),
        "email":               str(row.get("email", "")),
        "dob":                 str(row.get("dob", "")),
        "programme_code":      str(row.get("programme_code", "")),
        "application_status":  str(row.get("application_status", "")),
        "submitted_date":      str(row.get("submitted_date", "")),
    }


def normalise_applicants(rows: list) -> list:
    """
    Normalise a list of raw Oracle applicant dicts.

    :param rows: list of raw applicant dicts
    :return:     list of normalised applicant dicts
    """
    return [normalise_applicant(row) for row in rows]
