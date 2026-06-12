"""Geometric primitives: points, lines, distances, angles."""

from collections.abc import Sequence

import numpy as np

Point = tuple[float, float]


def distance(p: Sequence[float], q: Sequence[float]) -> float:
    """Euclidean distance between two points."""
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    return float(np.linalg.norm(q - p))


def midpoint(p: Sequence[float], q: Sequence[float]) -> Point:
    """Midpoint between two points."""
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    mid = (p + q) / 2
    return (float(mid[0]), float(mid[1]))


def slope(p: Sequence[float], q: Sequence[float]) -> float | None:
    """
    Slope of the line through p and q.

    Returns None for vertical lines (|dx| < 1e-12).
    """
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    dx = q[0] - p[0]
    dy = q[1] - p[1]
    if abs(dx) < 1e-12:
        return None
    return float(dy / dx)


def unit_direction(p: Sequence[float], q: Sequence[float]) -> Point:
    """
    Unit direction vector from p to q.

    Raises ValueError if p == q.
    """
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    d = q - p
    norm = np.linalg.norm(d)
    if norm < 1e-12:
        raise ValueError("zero-length vector")
    return (float(d[0] / norm), float(d[1] / norm))


def angle_between_lines(d1: Sequence[float], d2: Sequence[float]) -> float:
    """
    Unsigned angle in degrees between two undirected lines given direction vectors.

    Result in [0, 90]. Implementation: cosang = |d1·d2| / (|d1||d2|); clipped to [0,1];
    returns degrees(acos).
    """
    d1 = np.asarray(d1, dtype=float)
    d2 = np.asarray(d2, dtype=float)
    norm1 = np.linalg.norm(d1)
    norm2 = np.linalg.norm(d2)
    if norm1 < 1e-12 or norm2 < 1e-12:
        return 0.0
    cosang = abs(float(np.dot(d1, d2))) / (norm1 * norm2)
    cosang = np.clip(cosang, 0.0, 1.0)
    return float(np.degrees(np.arccos(cosang)))


def polyline_length(points: Sequence[Sequence[float]]) -> float:
    """Sum of segment lengths in a polyline."""
    points = np.asarray(points, dtype=float)
    if len(points) < 2:
        return 0.0
    diffs = np.diff(points, axis=0)
    lengths = np.linalg.norm(diffs, axis=1)
    return float(np.sum(lengths))


def resample_polyline(points: Sequence[Sequence[float]], n: int) -> np.ndarray:
    """
    Resample polyline to n points uniformly spaced by arc length.

    Linear interpolation; includes endpoints. n >= 2.
    """
    points = np.asarray(points, dtype=float)
    if n < 2:
        raise ValueError("n must be >= 2")

    # Compute cumulative arc length
    if len(points) < 2:
        return points

    diffs = np.diff(points, axis=0)
    segment_lengths = np.linalg.norm(diffs, axis=1)
    cumul = np.concatenate([[0], np.cumsum(segment_lengths)])
    total_length = cumul[-1]

    if total_length < 1e-12:
        # Degenerate: all points are the same
        return np.repeat(points[:1], n, axis=0)

    # Target arc-length positions
    target_positions = np.linspace(0, total_length, n)

    # Interpolate
    result = np.interp(target_positions, cumul, points[:, 0])[:, None]
    result = np.hstack([result, np.interp(target_positions, cumul, points[:, 1])[:, None]])
    return result


def perpendicular_slope(m: float | None) -> float | None:
    """
    Perpendicular slope.

    perpendicular(None) = 0.0 (horizontal perpendicular to vertical)
    perpendicular(0.0) = None (vertical perpendicular to horizontal)
    perpendicular(m) = -1/m (else)
    """
    if m is None:
        return 0.0
    if m == 0.0:
        return None
    return -1.0 / m
