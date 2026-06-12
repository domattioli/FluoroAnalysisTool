"""Tests for DHS procedure."""

import pytest

from fluoroanalysis.geometry.ellipse import Ellipse
from fluoroanalysis.io.results import parse_dhs_result, serialize_dhs_result
from fluoroanalysis.procedures.dhs import DHSProcedure


class TestDHSProcedure:
    """Test DHS Tip-Apex Distance procedure."""

    def test_dhs_setup(self):
        """Test basic DHS setup."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            wire=((100, -74), (37, -26)),
            wire_width_px=10,
            wire_width_mm=2,
        )
        assert proc.head is not None
        assert proc.neck is not None
        assert proc.wire is not None

    def test_dhs_bisector(self):
        """Test bisector computation."""
        # Circle at origin, radius 50
        # Neck from (-30, -40) to (30, 40): slope = 4/3, midpoint (0, 0)
        # Perpendicular slope = -3/4
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
        )
        bis = proc.bisector()
        assert bis is not None
        # Should intersect circle at approximately (-40, 30) and (40, -30)
        assert bis[0][0] == pytest.approx(-40.0, abs=1e-9)
        assert bis[0][1] == pytest.approx(30.0, abs=1e-9)
        assert bis[1][0] == pytest.approx(40.0, abs=1e-9)
        assert bis[1][1] == pytest.approx(-30.0, abs=1e-9)

    def test_dhs_bisector_flipped(self):
        """Test bisector with apex flipped."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            apex_flipped=True,
        )
        bis = proc.bisector()
        assert bis is not None
        # Apex should be flipped
        assert bis[0][0] == pytest.approx(40.0, abs=1e-9)
        assert bis[0][1] == pytest.approx(-30.0, abs=1e-9)

    def test_dhs_not_ready(self):
        """Test procedure not ready."""
        proc = DHSProcedure()
        assert not proc.ready()
        with pytest.raises(ValueError):
            proc.evaluate()

    def test_dhs_ready(self):
        """Test procedure ready."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            wire=((100, -74), (37, -26)),
            wire_width_px=10,
            wire_width_mm=2,
        )
        assert proc.ready()

    def test_dhs_evaluate(self):
        """Test DHS evaluation."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            wire=((100, -74), (37, -26)),
            wire_width_px=10,
            wire_width_mm=2,
        )
        metrics = proc.evaluate()

        # Wire tip (37, -26) to apex (-40, 30)
        expected_tad_px = ((37 - (-40)) ** 2 + (-26 - 30) ** 2) ** 0.5
        assert metrics.tad_px == pytest.approx(expected_tad_px, abs=1e-6)
        assert metrics.tad_mm == pytest.approx(expected_tad_px / 5.0, abs=1e-6)
        assert metrics.tad_inch == pytest.approx(metrics.tad_mm / 25.4, abs=1e-6)
        assert metrics.px_per_mm == pytest.approx(5.0)

    def test_dhs_evaluate_no_calibration(self):
        """Test DHS evaluation without wire width calibration."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            wire=((100, -74), (37, -26)),
        )
        metrics = proc.evaluate()
        assert metrics.tad_mm is None
        assert metrics.px_per_mm is None
        assert "calibration" in metrics.warnings[0].lower()

    def test_dhs_tad_warning(self):
        """Test TAD warning for large distance."""
        proc = DHSProcedure(
            head=Ellipse(center_x=0, center_y=0, semi_x=50, semi_y=50),
            neck=((-30, -40), (30, 40)),
            wire=((100, -74), (37, -26)),
            wire_width_px=1,
            wire_width_mm=1,  # px_per_mm = 1, so tad_mm = tad_px
        )
        metrics = proc.evaluate()
        assert any("exceeds 25 mm" in w for w in metrics.warnings)

    def test_dhs_to_result_data(self):
        """Test conversion to result data."""
        proc = DHSProcedure(
            head=Ellipse(center_x=5, center_y=-3, semi_x=4, semi_y=2),
            neck=((1, -5), (9, -1)),
            wire=((10, -10), (5, -5)),
            wire_width_px=10,
            wire_width_mm=2,
        )
        data = proc.to_result_data()
        assert data.head is not None
        assert data.neck is not None
        assert len(data.wire.points) == 2
        assert data.metrics is not None

    def test_dhs_result_roundtrip(self):
        """Test serialization and deserialization."""
        proc = DHSProcedure(
            head=Ellipse(center_x=5, center_y=-3, semi_x=4, semi_y=2),
            neck=((1, -5), (9, -1)),
            wire=((10, -10), (5, -5)),
            wire_width_px=10,
            wire_width_mm=2,
        )
        data1 = proc.to_result_data()

        # Serialize
        result_dict = serialize_dhs_result(data1)

        # Deserialize
        data2 = parse_dhs_result(result_dict)

        # Compare
        assert data2.head is not None
        assert data2.head.center_x == pytest.approx(5.0, abs=0.01)
        assert data2.head.center_y == pytest.approx(-3.0, abs=0.01)
        assert data2.head.semi_x == pytest.approx(4.0, abs=0.01)
        assert data2.head.semi_y == pytest.approx(2.0, abs=0.01)

        assert data2.neck is not None
        assert data2.neck[0][0] == pytest.approx(1.0, abs=0.01)
        assert data2.neck[1][0] == pytest.approx(9.0, abs=0.01)

        assert len(data2.wire.points) == 2
        assert data2.wire.width_px == pytest.approx(10.0, abs=0.01)
        assert data2.wire.width_mm == pytest.approx(2.0, abs=0.01)

    def test_dhs_off_origin_head(self):
        """Test DHS with ellipse off origin."""
        # Ellipse centered at (100, 100), semi-axes 50 x 40
        # Neck from (60, 70) to (140, 130): slope = 0.75, midpoint (100, 100)
        # Perpendicular slope = -4/3
        # Wire from (10, 180) to (70, 130), wire_width_px=16, wire_width_mm=2.5 → px_per_mm=6.4
        proc = DHSProcedure(
            head=Ellipse(center_x=100, center_y=100, semi_x=50, semi_y=40),
            neck=((60, 70), (140, 130)),
            wire=((10, 180), (70, 130)),
            wire_width_px=16,
            wire_width_mm=2.5,
        )

        # Check bisector (apex first by sorted order)
        bis = proc.bisector()
        assert bis is not None
        # Apex should be first intersection (sorted by x)
        assert bis[0] == pytest.approx((74.275213, 134.299716), abs=1e-4)
        # Other should be second
        assert bis[1] == pytest.approx((125.724787, 65.700284), abs=1e-4)

        # Check evaluate metrics
        metrics = proc.evaluate()
        # Wire tip (70, 130) to apex (74.275213, 134.299716)
        expected_tad_px = ((70 - 74.275213) ** 2 + (130 - 134.299716) ** 2) ** 0.5
        assert metrics.tad_px == pytest.approx(expected_tad_px, abs=1e-6)
        assert metrics.tad_mm == pytest.approx(expected_tad_px / 6.4, abs=1e-6)
        assert metrics.angle_deg == pytest.approx(13.3241, abs=1e-3)
