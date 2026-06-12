"""Ellipse fitting and intersection."""

from dataclasses import dataclass

import numpy as np

from .primitives import Point


@dataclass(frozen=True)
class Ellipse:
    """
    Axis-aligned ellipse: ((x-h)/a)^2 + ((y-k)/b)^2 = 1.

    Fields:
        center_x: h coordinate of center
        center_y: k coordinate of center
        semi_x: a semi-axis (x-direction)
        semi_y: b semi-axis (y-direction)
    """

    center_x: float
    center_y: float
    semi_x: float
    semi_y: float

    def __post_init__(self) -> None:
        """Validate positive semi-axes."""
        if self.semi_x <= 0 or self.semi_y <= 0:
            raise ValueError("semi-axes must be positive")

    @property
    def center(self) -> Point:
        """Center as (x, y)."""
        return (self.center_x, self.center_y)

    @property
    def left_xy(self) -> Point:
        """Left extreme point (minimum x)."""
        return (self.center_x - self.semi_x, self.center_y)

    @property
    def top_xy(self) -> Point:
        """Top extreme point (maximum y, in image coords where y grows downward)."""
        return (self.center_x, self.center_y + self.semi_y)

    def boundary_points(self, n: int = 100) -> np.ndarray:
        """
        Parametric boundary points: (h + a*cos(t), k + b*sin(t)), t in [0, 2π).

        Returns shape (n, 2).
        """
        t = np.linspace(0, 2 * np.pi, n, endpoint=False)
        x = self.center_x + self.semi_x * np.cos(t)
        y = self.center_y + self.semi_y * np.sin(t)
        return np.column_stack([x, y])

    def contains(self, p: Point, tol: float = 0.0) -> bool:
        """Check if point p is inside the ellipse (with tolerance)."""
        dx = p[0] - self.center_x
        dy = p[1] - self.center_y
        val = (dx / self.semi_x) ** 2 + (dy / self.semi_y) ** 2
        return val <= 1 + tol

    @classmethod
    def from_legacy(cls, left_xy: Point, top_xy: Point, center_xy: Point) -> "Ellipse":
        """
        Construct from legacy MATLAB format.

        Legacy format: Left_XY (min-x point), Top_XY (max-y point), Center_XY.
        """
        h, k = center_xy
        a = abs(h - left_xy[0])
        b = abs(top_xy[1] - k)
        return cls(center_x=h, center_y=k, semi_x=a, semi_y=b)

    def to_legacy(self) -> dict:
        """Convert to legacy MATLAB format (rounded to 2 decimals)."""
        return {
            "Left_XY": [round(self.center_x - self.semi_x, 2), round(self.center_y, 2)],
            "Top_XY": [round(self.center_x, 2), round(self.center_y + self.semi_y, 2)],
            "Center_XY": [round(self.center_x, 2), round(self.center_y, 2)],
        }


def fit_circle(points: np.ndarray) -> Ellipse:
    """
    Least-squares circle fit using Kåsa method.

    Solve [2x 2y 1][cx cy c]ᵀ = x²+y² via lstsq.
    r = sqrt(c + cx² + cy²).

    Requires >= 3 points.
    """
    points = np.asarray(points, dtype=float)
    if len(points) < 3:
        raise ValueError("fit_circle requires >= 3 points")

    x, y = points[:, 0], points[:, 1]
    A = np.column_stack([2 * x, 2 * y, np.ones(len(x))])
    b = x**2 + y**2

    coeffs, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
    cx, cy, c = coeffs
    r_sq = c + cx**2 + cy**2
    if r_sq < 0:
        raise ValueError("degenerate circle fit")
    r = float(np.sqrt(r_sq))
    return Ellipse(center_x=float(cx), center_y=float(cy), semi_x=r, semi_y=r)


def fit_ellipse_axis_aligned(points: np.ndarray) -> Ellipse:
    """
    Least-squares fit of axis-aligned ellipse: x² + B*y² + C*x + D*y + E = 0.

    Solve lstsq for [B, C, D, E] from x² = -(B*y² + C*x + D*y + E).
    Then h = -C/2, k = -D/(2B), a = sqrt(h² + B*k² - E), b = a/sqrt(B).

    Requires >= 3 points. If exactly 3, delegates to fit_circle.
    Raises ValueError if degenerate.
    """
    points = np.asarray(points, dtype=float)
    if len(points) < 3:
        raise ValueError("fit_ellipse_axis_aligned requires >= 3 points")

    if len(points) == 3:
        return fit_circle(points)

    x, y = points[:, 0], points[:, 1]
    x_sq = x**2

    # Setup: x² = -(B*y² + C*x + D*y + E)
    A = np.column_stack([y**2, x, y, np.ones(len(x))])
    b = -x_sq

    coeffs, _, _, _ = np.linalg.lstsq(A, b, rcond=None)
    B, C, D, E = coeffs

    if B <= 0:
        raise ValueError("degenerate ellipse fit")

    h = -C / 2
    k = -D / (2 * B)
    a_sq = h**2 + B * k**2 - E
    if a_sq <= 0:
        raise ValueError("degenerate ellipse fit")

    a = float(np.sqrt(a_sq))
    b = float(a / np.sqrt(B))
    return Ellipse(center_x=float(h), center_y=float(k), semi_x=a, semi_y=b)


def line_ellipse_intersections(
    point: Point, m: float | None, ellipse: Ellipse
) -> list[Point]:
    """
    Intersections of the infinite line through `point` with slope m (None=vertical) with ellipse.

    Solve analytically for the quadratic. Return 0, 1, or 2 points sorted by (x, then y).
    """
    h, k = ellipse.center_x, ellipse.center_y
    a, b = ellipse.semi_x, ellipse.semi_y
    x0, y0 = point

    # Translate to center-relative coordinates
    x0_prime = x0 - h
    y0_prime = y0 - k

    if m is None:
        # Vertical line: x' = x0'
        if abs(x0_prime) > a:
            return []
        # dy = b * sqrt(1 - (x0'/a)^2)
        dy = b * np.sqrt(max(0.0, 1 - (x0_prime / a) ** 2))
        if dy == 0:
            # Tangent point
            points = [(float(x0), float(k))]
        else:
            # Two intersection points
            points = [(float(x0), float(k - dy)), (float(x0), float(k + dy))]
    else:
        # Non-vertical line in centered coords: y' = m*x' + c where c = y0' - m*x0'
        c = y0_prime - m * x0_prime

        # Substitute into x'^2/a^2 + y'^2/b^2 = 1:
        # x'^2/a^2 + (m*x' + c)^2/b^2 = 1
        # b^2*x'^2 + a^2*(m*x' + c)^2 = a^2*b^2
        # b^2*x'^2 + a^2*(m^2*x'^2 + 2*m*c*x' + c^2) = a^2*b^2
        # (b^2 + a^2*m^2)*x'^2 + 2*a^2*m*c*x' + a^2*(c^2 - b^2) = 0

        A_coeff = b**2 + a**2 * m**2
        B_coeff = 2 * a**2 * m * c
        C_coeff = a**2 * (c**2 - b**2)

        disc = B_coeff**2 - 4 * A_coeff * C_coeff
        if disc < -1e-12:
            return []
        disc = max(0, disc)
        sqrt_disc = np.sqrt(disc)

        x1_prime = (-B_coeff + sqrt_disc) / (2 * A_coeff)
        x2_prime = (-B_coeff - sqrt_disc) / (2 * A_coeff)
        y1_prime = m * x1_prime + c
        y2_prime = m * x2_prime + c

        # Translate back to original coordinates
        points = [
            (float(x1_prime + h), float(y1_prime + k)),
            (float(x2_prime + h), float(y2_prime + k)),
        ]

    # Sort by x, then y, and remove duplicates
    points = sorted(set(points))
    return points
