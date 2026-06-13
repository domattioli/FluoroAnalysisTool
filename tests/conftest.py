"""Shared test fixtures and paths."""

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
EXAMPLE_CASE_DIR = REPO_ROOT / "data" / "Example_DICOM_Case"
