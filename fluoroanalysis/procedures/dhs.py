"""DHS Tip-Apex Distance measurement procedure."""

from dataclasses import dataclass
from typing import ClassVar

from ..geometry.ellipse import Ellipse, line_ellipse_intersections
from ..geometry.primitives import Point, angle_between_lines, distance, perpendicular_slope, slope
from ..io.results import DHSResultData, WireAnnotation
from .base import Procedure


@dataclass
class DHSMetrics:
    """DHS Tip-Apex Distance metrics."""

    tad_px: float
    tad_mm: float | None
    tad_inch: float | None
    angle_deg: float
    px_per_mm: float | None
    tip_apex: Point
    wire_tip: Point
    warnings: list[str]


@dataclass
class DHSProcedure(Procedure):
    """DHS Tip-Apex Distance measurement."""

    name: ClassVar[str] = "DHS Tip-Apex Distance"

    head: Ellipse | None = None
    neck: tuple[Point, Point] | None = None
    apex_flipped: bool = False
    wire: tuple[Point, Point] | None = None
    wire_width_px: float | None = None
    wire_width_mm: float | None = None
    side: str = ""

    def bisector(self) -> tuple[Point, Point] | None:
        """
        Compute bisector of femoral head perpendicular to neck.

        Returns (apex_candidate, other) sorted by x then y.
        If apex_flipped, returns swapped (other, apex_candidate).
        Returns None if computation fails.
        """
        if self.head is None or self.neck is None:
            return None

        # Midpoint of neck
        mid = ((self.neck[0][0] + self.neck[1][0]) / 2, (self.neck[0][1] + self.neck[1][1]) / 2)

        # Slope of neck
        neck_slope = slope(self.neck[0], self.neck[1])

        # Perpendicular slope
        perp_m = perpendicular_slope(neck_slope)

        # Intersections with head
        intersections = line_ellipse_intersections(mid, perp_m, self.head)
        if len(intersections) != 2:
            return None

        # Default order: as returned (sorted by x then y)
        apex_candidate = intersections[0]
        other = intersections[1]

        if self.apex_flipped:
            apex_candidate, other = other, apex_candidate

        return (apex_candidate, other)

    def tip_apex(self) -> Point | None:
        """Return the apex point (first element of bisector)."""
        bis = self.bisector()
        return bis[0] if bis else None

    def ready(self) -> bool:
        """Check if procedure has all required data and bisector is valid."""
        return (
            self.head is not None
            and self.neck is not None
            and self.wire is not None
            and self.bisector() is not None
        )

    def evaluate(self) -> DHSMetrics:
        """
        Evaluate DHS metrics.

        Raises ValueError if not ready.
        """
        if not self.ready():
            raise ValueError("procedure not ready")

        # Get tip_apex and wire_tip
        ta = self.tip_apex()
        assert ta is not None
        wire_tip = self.wire[1]

        # TAD in pixels
        tad_px = distance(wire_tip, ta)

        # Compute px_per_mm
        px_per_mm = None
        if self.wire_width_px is not None and self.wire_width_mm is not None:
            if self.wire_width_px > 0 and self.wire_width_mm > 0:
                px_per_mm = self.wire_width_px / self.wire_width_mm

        # TAD in mm and inches
        tad_mm = None
        tad_inch = None
        if px_per_mm is not None:
            tad_mm = tad_px / px_per_mm
            tad_inch = tad_mm / 25.4

        # Angle between wire and bisector
        wire_dir = (self.wire[1][0] - self.wire[0][0], self.wire[1][1] - self.wire[0][1])
        bis = self.bisector()
        assert bis is not None
        bisector_dir = (bis[1][0] - bis[0][0], bis[1][1] - bis[0][1])
        angle_deg = angle_between_lines(wire_dir, bisector_dir)

        # Warnings
        warnings = []
        if tad_mm is not None and tad_mm > 25.0:
            warnings.append(
                "TAD exceeds 25 mm (single-view) — elevated cut-out risk (Baumgaertner)"
            )
        if px_per_mm is None:
            warnings.append("No wire-width calibration — TAD reported in pixels only")

        return DHSMetrics(
            tad_px=tad_px,
            tad_mm=tad_mm,
            tad_inch=tad_inch,
            angle_deg=angle_deg,
            px_per_mm=px_per_mm,
            tip_apex=ta,
            wire_tip=wire_tip,
            warnings=warnings,
        )

    def to_result_data(self) -> DHSResultData:
        """Convert procedure to DHSResultData."""
        data = DHSResultData(head=self.head, neck=self.neck, bisector=self.bisector())

        if self.wire is not None:
            data.wire = WireAnnotation(
                points=list(self.wire),
                width_px=self.wire_width_px,
                width_mm=self.wire_width_mm,
            )

        if self.ready():
            try:
                metrics = self.evaluate()
                data.metrics = {
                    "TAD_PX": round(metrics.tad_px, 2),
                    "TAD_MM": round(metrics.tad_mm, 2) if metrics.tad_mm is not None else None,
                    "TAD_INCH": (
                        round(metrics.tad_inch, 2) if metrics.tad_inch is not None else None
                    ),
                    "Angle_DEG": round(metrics.angle_deg, 2),
                    "PX_per_MM": round(metrics.px_per_mm, 2) if metrics.px_per_mm else None,
                }
            except ValueError:
                pass

        return data
