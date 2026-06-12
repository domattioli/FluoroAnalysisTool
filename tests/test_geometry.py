"""Tests for geometry primitives and ellipse."""

import numpy as np
import pytest

from fluoroanalysis.geometry.ellipse import (
    Ellipse,
    fit_circle,
    fit_ellipse_axis_aligned,
    line_ellipse_intersections,
)
from fluoroanalysis.geometry.intersections import (
    polyline_segment_intersections,
    segment_intersection,
)
from fluoroanalysis.geometry.primitives import (
    angle_between_lines,
    distance,
    midpoint,
    perpendicular_slope,
    resample_polyline,
    slope,
    unit_direction,
)


class TestPrimitives:
    """Test geometric primitives."""

    def test_distance(self):
        """Test Euclidean distance."""
        assert distance((0, 0), (3, 4)) == pytest.approx(5.0)
        assert distance((0, 0), (0, 0)) == pytest.approx(0.0)

    def test_midpoint(self):
        """Test midpoint calculation."""
        assert midpoint((0, 0), (10, 10)) == pytest.approx((5.0, 5.0))
        assert midpoint((1, 2), (3, 4)) == pytest.approx((2.0, 3.0))

    def test_slope(self):
        """Test slope calculation."""
        assert slope((0, 0), (1, 2)) == pytest.approx(2.0)
        assert slope((0, 0), (1, 0)) == pytest.approx(0.0)
        assert slope((0, 0), (0, 1)) is None  # Vertical line

    def test_unit_direction(self):
        """Test unit direction vector."""
        u = unit_direction((0, 0), (3, 4))
        assert distance((0, 0), u) == pytest.approx(1.0)

    def test_unit_direction_zero_length(self):
        """Test unit direction on zero-length vector."""
        with pytest.raises(ValueError):
            unit_direction((0, 0), (0, 0))

    def test_perpendicular_slope(self):
        """Test perpendicular slope calculation."""
        assert perpendicular_slope(0.75) == pytest.approx(-4.0 / 3.0)
        assert perpendicular_slope(0.0) is None
        assert perpendicular_slope(None) == pytest.approx(0.0)

    def test_angle_between_lines(self):
        """Test angle between lines."""
        # 90 degree angle
        angle = angle_between_lines((1, 1), (1, -1))
        assert angle == pytest.approx(90.0, abs=1e-3)

        # Check specific angle
        angle = angle_between_lines((60, -50), (3, -4))
        assert angle == pytest.approx(13.3241, abs=1e-3)

        # Parallel lines
        angle = angle_between_lines((1, 2), (2, 4))
        assert angle == pytest.approx(0.0, abs=1e-3)

    def test_resample_polyline(self):
        """Test polyline resampling."""
        points = [(0, 0), (10, 0)]
        resampled = resample_polyline(points, 5)
        assert resampled.shape == (5, 2)
        assert resampled[0, 0] == pytest.approx(0.0)
        assert resampled[-1, 0] == pytest.approx(10.0)
        assert resampled[2, 0] == pytest.approx(5.0)  # Middle point


class TestEllipse:
    """Test ellipse fitting and operations."""

    def test_ellipse_creation(self):
        """Test basic ellipse creation."""
        ellipse = Ellipse(center_x=5, center_y=-3, semi_x=4, semi_y=2)
        assert ellipse.center == (5.0, -3.0)
        assert ellipse.left_xy == pytest.approx((1.0, -3.0))
        assert ellipse.top_xy == pytest.approx((5.0, -1.0))

    def test_ellipse_invalid(self):
        """Test invalid ellipse creation."""
        with pytest.raises(ValueError):
            Ellipse(center_x=5, center_y=5, semi_x=-1, semi_y=2)
        with pytest.raises(ValueError):
            Ellipse(center_x=5, center_y=5, semi_x=1, semi_y=0)

    def test_ellipse_from_legacy(self):
        """Test legacy ellipse construction."""
        ellipse = Ellipse.from_legacy((1, -3), (5, -1), (5, -3))
        assert ellipse.center_x == pytest.approx(5.0)
        assert ellipse.center_y == pytest.approx(-3.0)
        assert ellipse.semi_x == pytest.approx(4.0)
        assert ellipse.semi_y == pytest.approx(2.0)

    def test_ellipse_to_legacy(self):
        """Test legacy ellipse serialization."""
        ellipse = Ellipse(center_x=5, center_y=-3, semi_x=4, semi_y=2)
        legacy = ellipse.to_legacy()
        assert legacy["Left_XY"] == [1.0, -3.0]
        assert legacy["Top_XY"] == [5.0, -1.0]
        assert legacy["Center_XY"] == [5.0, -3.0]

    def test_ellipse_roundtrip(self):
        """Test ellipse legacy roundtrip."""
        original = Ellipse(center_x=5, center_y=-3, semi_x=4, semi_y=2)
        legacy = original.to_legacy()
        recovered = Ellipse.from_legacy(
            tuple(legacy["Left_XY"]), tuple(legacy["Top_XY"]), tuple(legacy["Center_XY"])
        )
        assert recovered.center_x == pytest.approx(original.center_x)
        assert recovered.center_y == pytest.approx(original.center_y)
        assert recovered.semi_x == pytest.approx(original.semi_x)
        assert recovered.semi_y == pytest.approx(original.semi_y)

    def test_fit_circle(self):
        """Test circle fitting."""
        # Circle center (2, 1), radius 5
        points = np.array(
            [(7, 1), (2, 6), (-3, 1), (2, -4)]
        )
        circle = fit_circle(points)
        assert circle.center_x == pytest.approx(2.0, abs=1e-9)
        assert circle.center_y == pytest.approx(1.0, abs=1e-9)
        assert circle.semi_x == pytest.approx(5.0, abs=1e-9)
        assert circle.semi_y == pytest.approx(5.0, abs=1e-9)

    def test_fit_circle_invalid(self):
        """Test circle fitting with too few points."""
        with pytest.raises(ValueError):
            fit_circle(np.array([[0, 0], [1, 1]]))

    def test_fit_ellipse_axis_aligned(self):
        """Test axis-aligned ellipse fitting."""
        # Create exact ellipse points
        h, k, a, b = 5, -3, 4, 2
        ellipse = Ellipse(center_x=h, center_y=k, semi_x=a, semi_y=b)
        points = ellipse.boundary_points(5)  # Sample 5 points

        fitted = fit_ellipse_axis_aligned(points)
        assert fitted.center_x == pytest.approx(h, abs=1e-6)
        assert fitted.center_y == pytest.approx(k, abs=1e-6)
        assert fitted.semi_x == pytest.approx(a, abs=1e-6)
        assert fitted.semi_y == pytest.approx(b, abs=1e-6)

    def test_line_ellipse_intersections(self):
        """Test line-ellipse intersections."""
        # Circle center (0, 0), radius 50
        # Line through (0, 0) with slope -3/4
        circle = Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50)
        points = line_ellipse_intersections((0, 0), -3.0 / 4.0, circle)

        assert len(points) == 2
        # Sorted by x: (-40, 30) then (40, -30)
        assert points[0][0] == pytest.approx(-40.0, abs=1e-9)
        assert points[0][1] == pytest.approx(30.0, abs=1e-9)
        assert points[1][0] == pytest.approx(40.0, abs=1e-9)
        assert points[1][1] == pytest.approx(-30.0, abs=1e-9)

    def test_ellipse_contains(self):
        """Test ellipse containment."""
        ellipse = Ellipse(center_x=0, center_y=0, semi_x=5, semi_y=3)
        assert ellipse.contains((0, 0))
        assert ellipse.contains((4, 0))
        assert ellipse.contains((0, 2))
        assert not ellipse.contains((6, 0))
        assert not ellipse.contains((0, 4))

    def test_line_ellipse_intersections_off_origin_sloped(self):
        """Test line-ellipse intersections with slope, off-origin ellipse."""
        # Ellipse centered at (100, 100), semi-axes a=50, b=40
        # Line through (100, 100) with slope -4/3
        ellipse = Ellipse(center_x=100, center_y=100, semi_x=50, semi_y=40)
        points = line_ellipse_intersections((100, 100), -4.0 / 3.0, ellipse)

        assert len(points) == 2
        # Expected: (74.27521..., 134.29971...) and (125.72478..., 65.70028...)
        assert points[0] == pytest.approx((74.275213, 134.299716), rel=1e-6)
        assert points[1] == pytest.approx((125.724787, 65.700284), rel=1e-6)

    def test_line_ellipse_intersections_off_origin_vertical_horizontal(self):
        """Test vertical and horizontal lines through off-origin ellipse."""
        # Ellipse centered at (100, 100), semi-axes a=50, b=40
        ellipse = Ellipse(center_x=100, center_y=100, semi_x=50, semi_y=40)

        # Vertical line through (100, 100)
        points_vert = line_ellipse_intersections((100, 100), None, ellipse)
        assert len(points_vert) == 2
        assert points_vert[0] == pytest.approx((100.0, 60.0), abs=1e-6)
        assert points_vert[1] == pytest.approx((100.0, 140.0), abs=1e-6)

        # Horizontal line through (100, 100) (slope 0)
        points_horiz = line_ellipse_intersections((100, 100), 0.0, ellipse)
        assert len(points_horiz) == 2
        assert points_horiz[0] == pytest.approx((50.0, 100.0), abs=1e-6)
        assert points_horiz[1] == pytest.approx((150.0, 100.0), abs=1e-6)

    def test_line_ellipse_intersections_tangent_and_miss(self):
        """Test tangent and miss cases for off-origin ellipse."""
        # Ellipse centered at (100, 100), semi-axes a=50, b=40
        ellipse = Ellipse(center_x=100, center_y=100, semi_x=50, semi_y=40)

        # Vertical tangent at x=150 (right extreme)
        points_tangent = line_ellipse_intersections((150, 100), None, ellipse)
        assert len(points_tangent) == 1
        assert points_tangent[0] == pytest.approx((150.0, 100.0), abs=1e-6)

        # Vertical line outside ellipse at x=151 (misses)
        points_miss = line_ellipse_intersections((151, 100), None, ellipse)
        assert len(points_miss) == 0

    def test_line_ellipse_intersections_not_through_center(self):
        """Test line-ellipse intersections not passing through center."""
        # Ellipse centered at (10, -5), semi-axes a=5, b=3
        ellipse = Ellipse(center_x=10, center_y=-5, semi_x=5, semi_y=3)

        # Vertical line through (13, 0): x' = 3
        # dy = 3 * sqrt(1 - (3/5)^2) = 3 * sqrt(1 - 0.36) = 3 * sqrt(0.64) = 3 * 0.8 = 2.4
        # Points: (13, -5 - 2.4) = (13, -7.4) and (13, -5 + 2.4) = (13, -2.6)
        points = line_ellipse_intersections((13, 0), None, ellipse)
        assert len(points) == 2
        assert points[0] == pytest.approx((13.0, -7.4), abs=1e-6)
        assert points[1] == pytest.approx((13.0, -2.6), abs=1e-6)


class TestIntersections:
    """Test intersection utilities."""

    def test_segment_intersection(self):
        """Test segment-segment intersection."""
        # Crossing segments
        inter = segment_intersection((0, 0), (10, 10), (0, 10), (10, 0))
        assert inter == pytest.approx((5, 5))

    def test_segment_intersection_parallel(self):
        """Test segment-segment intersection with parallel segments."""
        inter = segment_intersection((0, 0), (10, 0), (0, 1), (10, 1))
        assert inter is None

    def test_segment_intersection_disjoint(self):
        """Test segment-segment intersection with disjoint segments."""
        inter = segment_intersection((0, 0), (1, 1), (2, 2), (3, 3))
        assert inter is None

    def test_polyline_segment_intersections(self):
        """Test polyline-segment intersections."""
        polyline = [(10, 50), (10, -50)]
        inter = polyline_segment_intersections(polyline, (0, 0), (100, 0))
        assert len(inter) == 1
        assert inter[0] == pytest.approx((10, 0))
