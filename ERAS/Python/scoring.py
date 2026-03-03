"""
scoring.py
Scoring algorithm helpers for ERAS ranking calculations.
"""


def calculate_composite_score(academic: float, interview: float,
                               statement: float, weights: dict) -> float:
    """
    Calculate a weighted composite score from individual components.

    :param academic:  Academic score (0-100)
    :param interview: Interview score (0-100)
    :param statement: Personal statement score (0-100)
    :param weights:   Dict with keys 'academic', 'interview', 'statement'
                      (values should sum to 1.0)
    :return:          Composite score (0-100)
    """
    w_academic   = float(weights.get("academic",   0.4))
    w_interview  = float(weights.get("interview",  0.4))
    w_statement  = float(weights.get("statement",  0.2))
    return (academic * w_academic +
            interview * w_interview +
            statement * w_statement)


def rank_by_score(applicants: list) -> list:
    """
    Sort applicants by composite_score descending and assign rank positions.

    :param applicants: list of dicts, each must have a 'composite_score' key
    :return:           sorted list with 'rank_position' (1-based) added
    """
    sorted_applicants = sorted(
        applicants,
        key=lambda a: float(a.get("composite_score", 0)),
        reverse=True
    )
    for idx, applicant in enumerate(sorted_applicants, start=1):
        applicant["rank_position"] = idx
    return sorted_applicants


def normalise_scores(scores: list) -> list:
    """
    Normalise a list of numeric scores to a 0-100 scale.

    :param scores: list of numeric scores
    :return:       list of normalised scores (floats, 0-100)
    """
    if not scores:
        return []
    min_s = min(scores)
    max_s = max(scores)
    if max_s == min_s:
        return [100.0] * len(scores)
    return [
        round((s - min_s) / (max_s - min_s) * 100, 4)
        for s in scores
    ]
