"""Tests for PSHF procedure."""

import pytest

from fluoroanalysis.io.results import WireAnnotation
from fluoroanalysis.procedures.pshf import PSHFProcedure


class TestPSHFProcedure:
    """Test Pediatric Supracondylar Humerus Fracture procedure."""

    def test_pshf_setup(self):
        """Test basic PSHF setup."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(10, 50), (10, -50)]),
                WireAnnotation(points=[(50, 60), (50, -40)]),
                WireAnnotation(points=[(90, 55), (90, -45)]),
            ],
        )
        assert proc.fracture is not None
        assert len(proc.wires) == 3

    def test_pshf_not_ready(self):
        """Test procedure not ready."""
        proc = PSHFProcedure()
        assert not proc.ready()
        with pytest.raises(ValueError):
            proc.evaluate()

    def test_pshf_ready(self):
        """Test procedure ready."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(10, 50), (10, -50)]),
                WireAnnotation(points=[(50, 60), (50, -40)]),
            ],
        )
        assert proc.ready()

    def test_pshf_evaluate(self):
        """Test PSHF evaluation with 3 wires."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(10, 50), (10, -50)]),
                WireAnnotation(points=[(50, 60), (50, -40)]),
                WireAnnotation(points=[(90, 55), (90, -45)]),
            ],
        )
        metrics = proc.evaluate()

        # Fracture width
        assert metrics.fracture_width_px == pytest.approx(100.0)

        # All wires should cross at y=0
        assert len(metrics.intersections) == 3
        assert metrics.intersections[0] == pytest.approx((10, 0), abs=1e-5)
        assert metrics.intersections[1] == pytest.approx((50, 0), abs=1e-5)
        assert metrics.intersections[2] == pytest.approx((90, 0), abs=1e-5)

        # Breadths: 1-2, 1-3, 2-3
        assert "1-2" in metrics.breadths_px
        assert "1-3" in metrics.breadths_px
        assert "2-3" in metrics.breadths_px
        assert metrics.breadths_px["1-2"] == pytest.approx(40.0, abs=1e-5)
        assert metrics.breadths_px["1-3"] == pytest.approx(80.0, abs=1e-5)
        assert metrics.breadths_px["2-3"] == pytest.approx(40.0, abs=1e-5)

        # Max breadth
        assert metrics.max_breadth_px == pytest.approx(80.0, abs=1e-5)

        # Breadth ratio
        assert metrics.breadth_ratio == pytest.approx(0.8, abs=1e-5)

        # Spacing ratio (max / min = 80 / 40 = 2.0)
        assert metrics.spacing_ratio == pytest.approx(2.0, abs=1e-5)

    def test_pshf_wire_not_crossing(self):
        """Test PSHF with wire not crossing fracture."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(10, 50), (10, -50)]),
                WireAnnotation(points=[(50, 60), (50, 10)]),  # Doesn't cross y=0
            ],
        )
        metrics = proc.evaluate()
        assert metrics.intersections[1] is None
        assert any("Wire 2" in w for w in metrics.warnings)
        # Breadths empty since second intersection missing
        assert len(metrics.breadths_px) == 0

    def test_pshf_two_wires_lateral(self):
        """Test PSHF with 2 wires (lateral mode)."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(25, 50), (25, -50)]),
                WireAnnotation(points=[(75, 50), (75, -50)]),
            ],
        )
        assert proc.ready()
        metrics = proc.evaluate()
        assert metrics.breadth_ratio == pytest.approx(0.5, abs=1e-5)

    def test_pshf_to_result_data(self):
        """Test conversion to result data."""
        proc = PSHFProcedure(
            fracture=((0, 0), (100, 0)),
            wires=[
                WireAnnotation(points=[(10, 50), (10, -50)], width_px=5, width_mm=1),
                WireAnnotation(points=[(50, 60), (50, -40)]),
            ],
        )
        data = proc.to_result_data()
        assert data.fracture is not None
        assert len(data.wires) == 2
        assert data.metrics is not None
