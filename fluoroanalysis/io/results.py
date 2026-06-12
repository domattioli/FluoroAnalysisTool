"""JSON-lines results store, backward-compatible with legacy MATLAB format."""

import json
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

from ..geometry.ellipse import Ellipse
from ..geometry.primitives import Point


@dataclass
class WireAnnotation:
    """Wire annotation with optional width measurements."""

    points: list[Point] = field(default_factory=list)
    width_px: float | None = None
    width_mm: float | None = None


@dataclass
class DHSResultData:
    """DHS Tip-Apex Distance result data."""

    head: Ellipse | None = None
    neck: tuple[Point, Point] | None = None
    bisector: tuple[Point, Point] | None = None
    wire: WireAnnotation = field(default_factory=WireAnnotation)
    metrics: dict = field(default_factory=dict)


@dataclass
class PSHFResultData:
    """Pediatric Supracondylar Humerus Fracture result data."""

    fracture: tuple[Point, Point] | None = None
    wires: list[WireAnnotation] = field(default_factory=list)
    metrics: dict = field(default_factory=dict)


@dataclass
class FluoroRecord:
    """Single fluoroscopy result record."""

    case_id: str = ""
    file_name: str = ""
    surgeon: str = "Unknown"
    date_time_stamp: str = ""
    view: str = ""
    procedure: str = ""
    result: dict = field(default_factory=dict)
    side: str = ""
    tag: str = ""
    user: str = ""
    modified: str = ""

    def to_json_dict(self) -> dict:
        """Convert to legacy MATLAB JSON format with exact key order."""
        return {
            "CaseID": self.case_id,
            "FileName": self.file_name,
            "Surgeon": self.surgeon,
            "DateTimeStamp": self.date_time_stamp,
            "View": self.view,
            "Procedure": self.procedure,
            "Result": self.result,
            "Side": self.side,
            "Tag": self.tag,
            "User": self.user,
            "Modified": self.modified,
        }

    @classmethod
    def from_json_dict(cls, d: dict) -> "FluoroRecord":
        """Construct from legacy JSON dict (tolerant to missing keys)."""
        user = d.get("User", "")
        if isinstance(user, list):
            # Legacy empty list [] or list of strings
            user = " ".join(str(u) for u in user if u) if user else ""

        return cls(
            case_id=d.get("CaseID", ""),
            file_name=d.get("FileName", ""),
            surgeon=d.get("Surgeon", "Unknown"),
            date_time_stamp=d.get("DateTimeStamp", ""),
            view=d.get("View", ""),
            procedure=d.get("Procedure", ""),
            result=d.get("Result", {}),
            side=d.get("Side", ""),
            tag=d.get("Tag", ""),
            user=user,
            modified=d.get("Modified", ""),
        )


def load_results(path: str | Path) -> list[FluoroRecord]:
    """
    Load results from JSON-lines file.

    Blank lines are skipped. For each non-blank line, finds first "{",
    then json.loads the remainder. Silently skips unparseable lines.
    """
    path = Path(path)
    records = []

    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                # Find first '{'
                idx = line.find("{")
                if idx == -1:
                    continue
                json_str = line[idx:]
                try:
                    d = json.loads(json_str)
                    records.append(FluoroRecord.from_json_dict(d))
                except json.JSONDecodeError:
                    continue
    except FileNotFoundError:
        pass

    return records


def save_record(path: str | Path, record: FluoroRecord) -> None:
    """
    Save record to JSON-lines file with read-modify-write.

    Updates line with matching file_name, else appends.
    Sets record.modified to now before writing.
    """
    path = Path(path)

    # Set modified timestamp
    now = datetime.now()
    record.modified = now.strftime("%d-%b-%Y %H:%M:%S")

    # Load existing records
    existing_records = load_results(path)

    # Replace or append
    found = False
    for i, rec in enumerate(existing_records):
        if rec.file_name == record.file_name:
            existing_records[i] = record
            found = True
            break
    if not found:
        existing_records.append(record)

    # Write all records back
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        for rec in existing_records:
            f.write(json.dumps(rec.to_json_dict()) + "\n")


def delete_record(path: str | Path, file_name: str) -> bool:
    """Delete record by file_name. Return True if deleted, False if not found."""
    path = Path(path)
    records = load_results(path)

    original_len = len(records)
    records = [r for r in records if r.file_name != file_name]

    if len(records) < original_len:
        with open(path, "w") as f:
            for rec in records:
                f.write(json.dumps(rec.to_json_dict()) + "\n")
        return True
    return False


def parse_dhs_result(result: dict) -> DHSResultData:
    """
    Parse DHS result dict, handling legacy shapes A, B, and modern.

    Legacy A: Femoral_Head {...}, Femoral_Neck [[x,y],[x,y]], Wire {XY, PX_Width, MM_Width}
    Legacy B: Femoral_Head {...}, Femoral_Neck {Neck_XY, Bisector_XY}, Wire_Slope, Wire_Width
    Modern: Current schema
    """
    data = DHSResultData()

    # Parse Femoral_Head
    head_data = result.get("Femoral_Head")
    if head_data and isinstance(head_data, dict):
        try:
            left_xy = head_data.get("Left_XY")
            top_xy = head_data.get("Top_XY")
            center_xy = head_data.get("Center_XY")
            if left_xy and top_xy and center_xy:
                data.head = Ellipse.from_legacy(
                    (float(left_xy[0]), float(left_xy[1])),
                    (float(top_xy[0]), float(top_xy[1])),
                    (float(center_xy[0]), float(center_xy[1])),
                )
        except (TypeError, ValueError, IndexError):
            pass

    # Parse Femoral_Neck (legacy A shape: bare 2x2 array)
    neck_data = result.get("Femoral_Neck")
    if neck_data:
        if isinstance(neck_data, list) and len(neck_data) == 2:
            try:
                p1 = (float(neck_data[0][0]), float(neck_data[0][1]))
                p2 = (float(neck_data[1][0]), float(neck_data[1][1]))
                data.neck = (p1, p2)
            except (TypeError, ValueError, IndexError):
                pass
        elif isinstance(neck_data, dict):
            # Legacy B shape: {Neck_XY, Bisector_XY}
            neck_xy = neck_data.get("Neck_XY")
            if neck_xy and isinstance(neck_xy, list) and len(neck_xy) == 2:
                try:
                    p1 = (float(neck_xy[0][0]), float(neck_xy[0][1]))
                    p2 = (float(neck_xy[1][0]), float(neck_xy[1][1]))
                    data.neck = (p1, p2)
                except (TypeError, ValueError, IndexError):
                    pass

            bisector_xy = neck_data.get("Bisector_XY")
            if bisector_xy and isinstance(bisector_xy, list) and len(bisector_xy) == 2:
                try:
                    p1 = (float(bisector_xy[0][0]), float(bisector_xy[0][1]))
                    p2 = (float(bisector_xy[1][0]), float(bisector_xy[1][1]))
                    data.bisector = (p1, p2)
                except (TypeError, ValueError, IndexError):
                    pass

    # Parse Wire (legacy A shape)
    wire_data = result.get("Wire")
    if isinstance(wire_data, dict):
        xy = wire_data.get("XY")
        if xy and isinstance(xy, list) and len(xy) > 0:
            try:
                data.wire.points = [(float(p[0]), float(p[1])) for p in xy]
            except (TypeError, ValueError, IndexError):
                pass

        px_width = wire_data.get("PX_Width")
        if px_width and not isinstance(px_width, list):
            try:
                data.wire.width_px = float(px_width)
            except (TypeError, ValueError):
                pass

        mm_width = wire_data.get("MM_Width")
        if mm_width and not isinstance(mm_width, list):
            try:
                data.wire.width_mm = float(mm_width)
            except (TypeError, ValueError):
                pass

    # Parse Wire_Slope and Wire_Width (legacy B shape)
    wire_slope = result.get("Wire_Slope")
    if wire_slope and isinstance(wire_slope, list) and len(wire_slope) == 2:
        try:
            p1 = (float(wire_slope[0][0]), float(wire_slope[0][1]))
            p2 = (float(wire_slope[1][0]), float(wire_slope[1][1]))
            data.wire.points = [p1, p2]
        except (TypeError, ValueError, IndexError):
            pass

    wire_width = result.get("Wire_Width")
    if isinstance(wire_width, dict):
        mm = wire_width.get("MM")
        if mm and not isinstance(mm, list):
            try:
                data.wire.width_mm = float(mm)
            except (TypeError, ValueError):
                pass
        px = wire_width.get("PX")
        if px and not isinstance(px, list):
            try:
                data.wire.width_px = float(px)
            except (TypeError, ValueError):
                pass

    # Parse Metrics
    metrics = result.get("Metrics")
    if isinstance(metrics, dict):
        data.metrics = metrics

    return data


def serialize_dhs_result(data: DHSResultData) -> dict:
    """Serialize DHSResultData to modern JSON shape (coordinates rounded to 2 decimals)."""
    result = {}

    # Femoral_Head
    if data.head:
        result["Femoral_Head"] = data.head.to_legacy()
    else:
        result["Femoral_Head"] = {}

    # Femoral_Neck and Bisector
    neck_obj = {}
    if data.neck:
        neck_obj["Neck_XY"] = [
            [round(data.neck[0][0], 2), round(data.neck[0][1], 2)],
            [round(data.neck[1][0], 2), round(data.neck[1][1], 2)],
        ]
    else:
        neck_obj["Neck_XY"] = []

    if data.bisector:
        neck_obj["Bisector_XY"] = [
            [round(data.bisector[0][0], 2), round(data.bisector[0][1], 2)],
            [round(data.bisector[1][0], 2), round(data.bisector[1][1], 2)],
        ]
    else:
        neck_obj["Bisector_XY"] = []

    result["Femoral_Neck"] = neck_obj

    # Wire
    wire_obj = {}
    if data.wire.points:
        wire_obj["XY"] = [[round(p[0], 2), round(p[1], 2)] for p in data.wire.points]
    else:
        wire_obj["XY"] = []

    wire_obj["PX_Width"] = data.wire.width_px if data.wire.width_px is not None else []
    wire_obj["MM_Width"] = data.wire.width_mm if data.wire.width_mm is not None else []

    result["Wire"] = wire_obj

    # Metrics
    result["Metrics"] = data.metrics

    return result


def parse_pshf_result(result: dict) -> PSHFResultData:
    """Parse PSHF result dict."""
    data = PSHFResultData()

    # Parse Fracture
    fracture_data = result.get("Fracture")
    if fracture_data and isinstance(fracture_data, list) and len(fracture_data) == 2:
        try:
            p1 = (float(fracture_data[0][0]), float(fracture_data[0][1]))
            p2 = (float(fracture_data[1][0]), float(fracture_data[1][1]))
            data.fracture = (p1, p2)
        except (TypeError, ValueError, IndexError):
            pass

    # Parse Wire(s)
    wire_data = result.get("Wire")
    if wire_data:
        if isinstance(wire_data, dict):
            # Single wire dict
            wire_ann = _parse_wire_dict(wire_data)
            if wire_ann:
                data.wires.append(wire_ann)
        elif isinstance(wire_data, list):
            # List of wire dicts
            for wire_dict in wire_data:
                if isinstance(wire_dict, dict):
                    wire_ann = _parse_wire_dict(wire_dict)
                    if wire_ann:
                        data.wires.append(wire_ann)

    # Parse Metrics
    metrics = result.get("Metrics")
    if isinstance(metrics, dict):
        data.metrics = metrics

    return data


def _parse_wire_dict(wire_dict: dict) -> WireAnnotation | None:
    """Helper to parse a single wire dict."""
    wire_ann = WireAnnotation()

    xy = wire_dict.get("XY")
    if xy and isinstance(xy, list) and len(xy) > 0:
        try:
            wire_ann.points = [(float(p[0]), float(p[1])) for p in xy]
        except (TypeError, ValueError, IndexError):
            pass

    px_width = wire_dict.get("PX_Width")
    if px_width and not isinstance(px_width, list):
        try:
            wire_ann.width_px = float(px_width)
        except (TypeError, ValueError):
            pass

    mm_width = wire_dict.get("MM_Width")
    if mm_width and not isinstance(mm_width, list):
        try:
            wire_ann.width_mm = float(mm_width)
        except (TypeError, ValueError):
            pass

    return wire_ann if wire_ann.points else None


def serialize_pshf_result(data: PSHFResultData) -> dict:
    """Serialize PSHFResultData to JSON shape (coordinates rounded to 2 decimals)."""
    result = {}

    # Fracture
    if data.fracture:
        result["Fracture"] = [
            [round(data.fracture[0][0], 2), round(data.fracture[0][1], 2)],
            [round(data.fracture[1][0], 2), round(data.fracture[1][1], 2)],
        ]
    else:
        result["Fracture"] = []

    # Wires
    wire_list = []
    for wire in data.wires:
        wire_obj = {}
        if wire.points:
            wire_obj["XY"] = [[round(p[0], 2), round(p[1], 2)] for p in wire.points]
        else:
            wire_obj["XY"] = []
        wire_obj["PX_Width"] = wire.width_px if wire.width_px is not None else []
        wire_obj["MM_Width"] = wire.width_mm if wire.width_mm is not None else []
        wire_list.append(wire_obj)

    result["Wire"] = wire_list

    # Metrics
    result["Metrics"] = data.metrics

    return result


def dhs_table_rows(records: list[FluoroRecord]) -> list[dict]:
    """
    Extract DHS records into table rows.

    Columns: CaseID, FileName, Side, View, WEX, WEY, WTX, WTY,
    WWpx, WWmm, TAX, TAY, TAD_MM, Analyst.
    """
    rows = []
    for rec in records:
        if "DHS" not in rec.procedure:
            continue

        data = parse_dhs_result(rec.result)
        wire_entry = None
        wire_tip = None
        if data.wire.points and len(data.wire.points) > 0:
            wire_entry = data.wire.points[0]
            wire_tip = data.wire.points[-1]

        tip_apex = None
        if data.bisector and len(data.bisector) > 0:
            tip_apex = data.bisector[0]

        tad_mm = data.metrics.get("TAD_MM") if data.metrics else None

        analyst = rec.user if rec.user else rec.surgeon

        row = {
            "CaseID": rec.case_id,
            "FileName": rec.file_name,
            "Side": rec.side,
            "View": rec.view,
            "WEX": wire_entry[0] if wire_entry else None,
            "WEY": wire_entry[1] if wire_entry else None,
            "WTX": wire_tip[0] if wire_tip else None,
            "WTY": wire_tip[1] if wire_tip else None,
            "WWpx": data.wire.width_px,
            "WWmm": data.wire.width_mm,
            "TAX": tip_apex[0] if tip_apex else None,
            "TAY": tip_apex[1] if tip_apex else None,
            "TAD_MM": tad_mm,
            "Analyst": analyst,
        }
        rows.append(row)

    return rows
