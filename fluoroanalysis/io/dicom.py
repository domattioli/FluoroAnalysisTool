"""DICOM image loading and anonymization."""

from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pydicom

DEID_TAGS = (
    "PatientName",
    "PatientID",
    "PatientBirthDate",
    "PatientSex",
    "PatientAge",
    "OtherPatientIDs",
    "ReferringPhysicianName",
    "InstitutionName",
    "InstitutionAddress",
    "OperatorsName",
    "PerformingPhysicianName",
    "AccessionNumber",
)


@dataclass
class FluoroImage:
    """DICOM fluoroscopy image with metadata."""

    path: Path
    case_id: str
    file_name: str
    pixels: np.ndarray
    surgeon: str
    acquired_at: str
    window_center: float | None
    window_width: float | None
    pixel_spacing: tuple[float, float] | None

    @property
    def rows(self) -> int:
        """Number of rows in the image."""
        return self.pixels.shape[0]

    @property
    def cols(self) -> int:
        """Number of columns in the image."""
        return self.pixels.shape[1]


def load_dicom(path: str | Path) -> FluoroImage:
    """
    Load DICOM image and extract metadata.

    3-channel RGB is converted to grayscale via mean over last axis.
    Tolerates missing tags (sets defaults).
    """
    path = Path(path)
    ds = pydicom.dcmread(path)

    # Extract pixels
    pixels = ds.pixel_array
    if pixels.ndim == 3 and pixels.shape[2] == 3:
        # RGB → grayscale
        pixels = pixels.astype(float).mean(axis=2).astype(pixels.dtype)

    # Case ID: parent directory path
    case_id = str(path.parent)

    # File name: stem (no extension)
    file_name = path.stem

    # Surgeon: from PerformingPhysicianName
    surgeon = "Unknown"
    if hasattr(ds, "PerformingPhysicianName") and ds.PerformingPhysicianName:
        name_obj = ds.PerformingPhysicianName
        if hasattr(name_obj, "family_name") and hasattr(name_obj, "given_name"):
            parts = []
            if name_obj.family_name:
                parts.append(str(name_obj.family_name))
            if name_obj.given_name:
                parts.append(str(name_obj.given_name))
            if parts:
                surgeon = " ".join(parts)
        else:
            surgeon = str(name_obj)

    # Acquired at: from ContentDate and ContentTime
    acquired_at = ""
    content_date = getattr(ds, "ContentDate", None)
    content_time = getattr(ds, "ContentTime", None)
    if content_date and content_time:
        # Format: DD-Mon-YYYY HH:MM:SS
        # content_date is yyyymmdd, content_time is hhmmss
        try:
            date_str = str(content_date)
            time_str = str(content_time)
            if len(date_str) >= 8 and len(time_str) >= 6:
                year = date_str[0:4]
                month = date_str[4:6]
                day = date_str[6:8]
                hour = time_str[0:2]
                minute = time_str[2:4]
                second = time_str[4:6]

                months = [
                    "Jan",
                    "Feb",
                    "Mar",
                    "Apr",
                    "May",
                    "Jun",
                    "Jul",
                    "Aug",
                    "Sep",
                    "Oct",
                    "Nov",
                    "Dec",
                ]
                month_name = months[int(month) - 1] if 1 <= int(month) <= 12 else "Jan"

                acquired_at = f"{day}-{month_name}-{year} {hour}:{minute}:{second}"
        except (ValueError, IndexError):
            acquired_at = ""

    # Window center and width
    window_center = None
    window_width = None
    if hasattr(ds, "WindowCenter"):
        wc = ds.WindowCenter
        if isinstance(wc, (list, tuple)) and len(wc) > 0:
            window_center = float(wc[0])
        elif wc is not None:
            window_center = float(wc)
    if hasattr(ds, "WindowWidth"):
        ww = ds.WindowWidth
        if isinstance(ww, (list, tuple)) and len(ww) > 0:
            window_width = float(ww[0])
        elif ww is not None:
            window_width = float(ww)

    # Pixel spacing: from PixelSpacing or ImagerPixelSpacing
    pixel_spacing = None
    if hasattr(ds, "PixelSpacing") and ds.PixelSpacing:
        try:
            ps = ds.PixelSpacing
            pixel_spacing = (float(ps[0]), float(ps[1]))
        except (TypeError, IndexError, ValueError):
            pass
    if pixel_spacing is None and hasattr(ds, "ImagerPixelSpacing") and ds.ImagerPixelSpacing:
        try:
            ips = ds.ImagerPixelSpacing
            pixel_spacing = (float(ips[0]), float(ips[1]))
        except (TypeError, IndexError, ValueError):
            pass

    return FluoroImage(
        path=path,
        case_id=case_id,
        file_name=file_name,
        pixels=pixels,
        surgeon=surgeon,
        acquired_at=acquired_at,
        window_center=window_center,
        window_width=window_width,
        pixel_spacing=pixel_spacing,
    )


def list_case_files(directory: str | Path) -> list[Path]:
    """List all .dcm files (case-insensitive extension) in directory, sorted."""
    directory = Path(directory)
    files = sorted(directory.glob("*.dcm")) + sorted(directory.glob("*.DCM"))
    # Remove duplicates while preserving sort order
    seen = set()
    result = []
    for f in files:
        if f.resolve() not in seen:
            seen.add(f.resolve())
            result.append(f)
    return result


def deidentify(src: str | Path, dst: str | Path) -> list[str]:
    """
    De-identify DICOM by blanking DEID_TAGS.

    Returns list of tags that were blanked.
    """
    src = Path(src)
    dst = Path(dst)

    ds = pydicom.dcmread(src)
    blanked = []

    for tag in DEID_TAGS:
        if hasattr(ds, tag):
            setattr(ds, tag, "")
            blanked.append(tag)

    ds.save_as(dst, enforce_file_format=True)
    return blanked
