"""Segment and polyline intersection utilities."""

from collections.abc import Sequence

import numpy as np

from .primitives import Point


def segment_intersection(p1: Point, p2: Point, q1: Point, q2: Point) -> Point | None:
    """
    Proper intersection of closed segments [p1, p2] and [q1, q2].

    Uses parametric cross-product method. Collinear/parallel → None.
    Touch at endpoints counts (t, u in [0, 1] with 1e-9 tolerance).
    """
    p1 = np.asarray(p1, dtype=float)
    p2 = np.asarray(p2, dtype=float)
    q1 = np.asarray(q1, dtype=float)
    q2 = np.asarray(q2, dtype=float)

    r = p2 - p1
    s = q2 - q1
    pq = q1 - p1

    # Cross product r × s
    cross_rs = r[0] * s[1] - r[1] * s[0]

    if abs(cross_rs) < 1e-12:
        # Parallel or collinear
        return None

    # t = (q1 - p1) × s / (r × s)
    # u = (q1 - p1) × r / (r × s)
    t = (pq[0] * s[1] - pq[1] * s[0]) / cross_rs
    u = (pq[0] * r[1] - pq[1] * r[0]) / cross_rs

    if -1e-9 <= t <= 1 + 1e-9 and -1e-9 <= u <= 1 + 1e-9:
        intersection = p1 + t * r
        return (float(intersection[0]), float(intersection[1]))

    return None


def polyline_segment_intersections(
    polyline: Sequence[Sequence[float]], q1: Point, q2: Point
) -> list[Point]:
    """
    Apply segment_intersection over consecutive polyline segments.

    Deduplicate points closer than 1e-6.
    """
    polyline = np.asarray(polyline, dtype=float)
    if len(polyline) < 2:
        return []

    intersections = []
    for i in range(len(polyline) - 1):
        p1 = (float(polyline[i][0]), float(polyline[i][1]))
        p2 = (float(polyline[i + 1][0]), float(polyline[i + 1][1]))
        inter = segment_intersection(p1, p2, q1, q2)
        if inter is not None:
            intersections.append(inter)

    # Deduplicate: remove points closer than 1e-6
    if not intersections:
        return []

    unique = [intersections[0]]
    for p in intersections[1:]:
        if all(np.linalg.norm(np.array(p) - np.array(u)) > 1e-6 for u in unique):
            unique.append(p)

    return unique
