"""Pediatric Supracondylar Humerus Fracture measurement procedure."""

from dataclasses import dataclass, field
from typing import ClassVar

from ..geometry.intersections import polyline_segment_intersections
from ..geometry.primitives import Point, angle_between_lines, distance, resample_polyline
from ..io.results import PSHFResultData, WireAnnotation
from .base import Procedure


@dataclass
class PSHFMetrics:
    """PSHF measurement metrics."""

    fracture_width_px: float
    intersections: list[Point | None]
    breadths_px: dict[str, float]
    max_breadth_px: float | None
    breadth_ratio: float | None
    spacing_ratio: float | None
    angles_deg: dict[str, float]
    warnings: list[str]


@dataclass
class PSHFProcedure(Procedure):
    """Pediatric Supracondylar Humerus Fracture measurement."""

    name: ClassVar[str] = "Pediatric Supracondylar Humerus Fracture"

    fracture: tuple[Point, Point] | None = None
    wires: list[WireAnnotation] = field(default_factory=list)

    def ready(self) -> bool:
        """Check if procedure has fracture and >= 2 wires with >= 2 points each."""
        if self.fracture is None:
            return False
        if len(self.wires) < 2:
            return False
        return all(len(wire.points) >= 2 for wire in self.wires)

    def evaluate(self) -> PSHFMetrics:
        """
        Evaluate PSHF metrics.

        Raises ValueError if not ready.
        """
        if not self.ready():
            raise ValueError("procedure not ready")

        assert self.fracture is not None

        # Fracture width
        fracture_width = distance(self.fracture[0], self.fracture[1])

        # Compute intersections with fracture for each wire
        intersections = []
        for wire in self.wires:
            # Resample wire polyline to 200 points
            resampled = resample_polyline(wire.points, 200)
            # Find intersections
            inter_pts = polyline_segment_intersections(resampled, self.fracture[0], self.fracture[1])
            if inter_pts:
                intersections.append(inter_pts[0])
            else:
                intersections.append(None)

        # Compute breadths (distance between pairs of intersections)
        breadths_px = {}
        for i in range(len(intersections)):
            for j in range(i + 1, len(intersections)):
                if intersections[i] is not None and intersections[j] is not None:
                    breadth = distance(intersections[i], intersections[j])
                    key = f"{i + 1}-{j + 1}"
                    breadths_px[key] = breadth

        # Max breadth and ratios
        max_breadth = None
        if breadths_px:
            max_breadth = max(breadths_px.values())

        breadth_ratio = None
        if max_breadth is not None and fracture_width > 0:
            breadth_ratio = max_breadth / fracture_width

        spacing_ratio = None
        if len(breadths_px) >= 2:
            breadths_list = list(breadths_px.values())
            max_b = max(breadths_list)
            min_b = min(breadths_list)
            if min_b > 0:
                spacing_ratio = max_b / min_b

        # Compute pairwise angles
        angles_deg = {}
        for i in range(len(self.wires)):
            for j in range(i + 1, len(self.wires)):
                wire_i = self.wires[i]
                wire_j = self.wires[j]
                if len(wire_i.points) >= 2 and len(wire_j.points) >= 2:
                    # Direction vectors (last - first)
                    dir_i = (
                        wire_i.points[-1][0] - wire_i.points[0][0],
                        wire_i.points[-1][1] - wire_i.points[0][1],
                    )
                    dir_j = (
                        wire_j.points[-1][0] - wire_j.points[0][0],
                        wire_j.points[-1][1] - wire_j.points[0][1],
                    )
                    angle = angle_between_lines(dir_i, dir_j)
                    key = f"Wire_{i + 1}_Wire_{j + 1}"
                    angles_deg[key] = angle

        # Warnings
        warnings = []
        for i, inter in enumerate(intersections):
            if inter is None:
                warnings.append(f"Wire {i + 1} does not cross the fracture line")

        return PSHFMetrics(
            fracture_width_px=fracture_width,
            intersections=intersections,
            breadths_px=breadths_px,
            max_breadth_px=max_breadth,
            breadth_ratio=breadth_ratio,
            spacing_ratio=spacing_ratio,
            angles_deg=angles_deg,
            warnings=warnings,
        )

    def to_result_data(self) -> PSHFResultData:
        """Convert procedure to PSHFResultData."""
        data = PSHFResultData(fracture=self.fracture, wires=self.wires)

        if self.ready():
            try:
                metrics = self.evaluate()
                data.metrics = {
                    "Fracture_Width_PX": round(metrics.fracture_width_px, 2),
                    "Max_Breadth_PX": (
                        round(metrics.max_breadth_px, 2)
                        if metrics.max_breadth_px is not None
                        else None
                    ),
                    "Breadth_Ratio": (
                        round(metrics.breadth_ratio, 2) if metrics.breadth_ratio is not None else None
                    ),
                    "Spacing_Ratio": (
                        round(metrics.spacing_ratio, 2) if metrics.spacing_ratio is not None else None
                    ),
                    "Angles_DEG": {k: round(v, 2) for k, v in metrics.angles_deg.items()},
                    "Breadths_PX": {k: round(v, 2) for k, v in metrics.breadths_px.items()},
                }
            except ValueError:
                pass

        return data
