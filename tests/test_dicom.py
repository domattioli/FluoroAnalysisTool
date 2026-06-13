"""Tests for DICOM I/O."""

import tempfile
from pathlib import Path

import numpy as np
import pytest

from fluoroanalysis.imaging.enhance import histogram_equalize, invert, to_pil_rgb, to_uint8
from fluoroanalysis.io.dicom import deidentify, list_case_files, load_dicom

REPO_ROOT = Path(__file__).resolve().parents[1]
EXAMPLE_CASE_DIR = REPO_ROOT / "data" / "Example_DICOM_Case"


class TestDICOMIO:
    """Test DICOM loading."""

    def test_list_case_files(self):
        """Test listing case files."""
        files = list_case_files(EXAMPLE_CASE_DIR)
        assert len(files) > 0
        assert all(f.suffix.lower() == ".dcm" for f in files)

    def test_load_dicom_basic(self):
        """Test loading a DICOM file."""
        dcm_files = sorted(list_case_files(EXAMPLE_CASE_DIR))
        assert len(dcm_files) > 0

        img = load_dicom(dcm_files[0])
        assert img.pixels.ndim == 2
        assert img.pixels.shape == (1024, 1024)
        assert img.rows == 1024
        assert img.cols == 1024
        assert img.pixels.dtype in (np.uint16, np.uint8)
        assert img.surgeon != ""
        assert img.window_center is not None
        assert img.window_width is not None

    def test_deidentify(self):
        """Test DICOM deidentification."""
        dcm_files = list_case_files(EXAMPLE_CASE_DIR)
        if len(dcm_files) == 0:
            pytest.skip("No DICOM files available")

        with tempfile.TemporaryDirectory() as tmp_dir:
            src = dcm_files[0]
            dst = Path(tmp_dir) / "anon.dcm"

            blanked = deidentify(src, dst)
            assert isinstance(blanked, list)
            assert len(blanked) > 0
            assert dst.exists()


class TestImaging:
    """Test image enhancement."""

    def test_to_uint8(self):
        """Test float to uint8 conversion."""
        img = np.array([[0.0, 100.0], [50.0, 100.0]], dtype=float)
        result = to_uint8(img)
        assert result.dtype == np.uint8
        assert result.min() == 0
        assert result.max() == 255

    def test_to_uint8_with_window(self):
        """Test float to uint8 with explicit window."""
        img = np.array([[0.0, 100.0], [50.0, 100.0]], dtype=float)
        result = to_uint8(img, window_center=50, window_width=100)
        assert result.dtype == np.uint8

    def test_histogram_equalize(self):
        """Test histogram equalization."""
        img = np.array([[0, 0, 255], [0, 255, 255], [255, 255, 255]], dtype=np.uint8)
        result = histogram_equalize(img)
        assert result.dtype == np.uint8
        assert result.shape == img.shape

    def test_invert(self):
        """Test image inversion."""
        img = np.array([[0, 128, 255]], dtype=np.uint8)
        result = invert(img)
        assert result[0, 0] == 255
        assert result[0, 1] == 127
        assert result[0, 2] == 0

    def test_invert_roundtrip(self):
        """Test double inversion is identity."""
        img = np.array([[10, 100, 200]], dtype=np.uint8)
        result = invert(invert(img))
        assert np.allclose(result, img)

    def test_to_pil_rgb(self):
        """Test PIL RGB conversion."""
        img = np.array([[0, 128, 255]], dtype=np.uint8)
        pil_img = to_pil_rgb(img)
        assert pil_img.mode == "RGB"
        assert pil_img.size == (3, 1)
