"""Tests for results I/O."""

from pathlib import Path

import pytest

from fluoroanalysis.io.results import (
    FluoroRecord,
    dhs_table_rows,
    find_results_file,
    load_results,
    parse_dhs_result,
    save_record,
)

REPO_ROOT = Path(__file__).resolve().parents[1]
EXAMPLE_CASE_DIR = REPO_ROOT / "data" / "Example_DICOM_Case"


class TestResultsIO:
    """Test results loading and saving."""

    def test_load_example_results(self):
        """Test loading real example results file."""
        results_path = EXAMPLE_CASE_DIR / "Example_DICOM_Case_Results.json"
        records = load_results(results_path)
        assert len(records) == 2

        # First record
        assert records[0].file_name == "IM-0001-0020"
        assert records[0].view == "AP"
        assert records[0].side == "Right"
        assert records[0].procedure == "DHS Tip-Apex Distance"

        # Second record
        assert records[1].file_name == "IM-0001-0022"
        assert records[1].view == "AP"

    def test_parse_dhs_result_legacy(self):
        """Test parsing legacy DHS result."""
        results_path = EXAMPLE_CASE_DIR / "Example_DICOM_Case_Results.json"
        records = load_results(results_path)

        # Parse first record (no wire, just head and neck)
        data = parse_dhs_result(records[0].result)
        assert data.head is not None
        assert data.head.center_x == pytest.approx(687.8, abs=0.1)
        assert data.head.center_y == pytest.approx(356.33, abs=0.1)
        assert data.neck is not None
        assert data.neck[0][0] == pytest.approx(589.9, abs=0.1)
        assert len(data.wire.points) == 0

        # Parse second record (with wire)
        data = parse_dhs_result(records[1].result)
        assert len(data.wire.points) == 11
        assert data.wire.width_px == pytest.approx(16.1, abs=0.1)
        assert data.wire.width_mm == pytest.approx(2.5, abs=0.1)

    def test_save_and_load_record(self, tmp_path):
        """Test saving and loading records."""
        results_file = tmp_path / "results.jsonl"

        # Create and save two records
        record1 = FluoroRecord(
            case_id="case1",
            file_name="img1",
            surgeon="Dr. A",
            procedure="DHS Tip-Apex Distance",
            result={"test": "data1"},
        )
        save_record(results_file, record1)

        record2 = FluoroRecord(
            case_id="case2",
            file_name="img2",
            surgeon="Dr. B",
            procedure="PSHF",
            result={"test": "data2"},
        )
        save_record(results_file, record2)

        # Load and verify
        loaded = load_results(results_file)
        assert len(loaded) == 2
        assert loaded[0].file_name == "img1"
        assert loaded[1].file_name == "img2"

    def test_update_record(self, tmp_path):
        """Test updating existing record."""
        results_file = tmp_path / "results.jsonl"

        # Save initial record
        record = FluoroRecord(
            case_id="case1", file_name="img1", surgeon="Dr. A", result={"v": 1}
        )
        save_record(results_file, record)

        # Update record
        record.result = {"v": 2}
        save_record(results_file, record)

        # Load and verify
        loaded = load_results(results_file)
        assert len(loaded) == 1
        assert loaded[0].result["v"] == 2
        assert loaded[0].modified != ""

    def test_fluoro_record_json_dict(self):
        """Test FluoroRecord JSON dict format."""
        record = FluoroRecord(
            case_id="case1",
            file_name="img1",
            surgeon="Dr. A",
            date_time_stamp="01-Jan-2020 12:00:00",
            view="AP",
            procedure="DHS",
            result={"key": "value"},
            side="Right",
            tag="tag1",
            user="user1",
            modified="02-Jan-2020 13:00:00",
        )
        d = record.to_json_dict()

        # Check key order (legacy format)
        keys = list(d.keys())
        assert keys == [
            "CaseID",
            "FileName",
            "Surgeon",
            "DateTimeStamp",
            "View",
            "Procedure",
            "Result",
            "Side",
            "Tag",
            "User",
            "Modified",
        ]

    def test_fluoro_record_from_dict_tolerant(self):
        """Test FluoroRecord from dict with missing keys."""
        d = {"FileName": "img1", "Result": {}}
        record = FluoroRecord.from_json_dict(d)
        assert record.file_name == "img1"
        assert record.surgeon == "Unknown"
        assert record.case_id == ""

    def test_fluoro_record_from_dict_user_list(self):
        """Test FluoroRecord from dict with user as list."""
        d = {"User": ["Dr.", "Smith"]}
        record = FluoroRecord.from_json_dict(d)
        assert record.user == "Dr. Smith"

    def test_dhs_table_rows(self):
        """Test DHS table row extraction."""
        records = [
            FluoroRecord(
                case_id="case1",
                file_name="img1",
                surgeon="Dr. A",
                procedure="DHS Tip-Apex Distance",
                side="Right",
                view="AP",
                user="analyst1",
                result={
                    "Femoral_Head": {
                        "Left_XY": [100, 200],
                        "Top_XY": [150, 150],
                        "Center_XY": [150, 200],
                    },
                    "Femoral_Neck": [[100, 200], [200, 300]],
                    "Wire": {
                        "XY": [[50, 400], [150, 300]],
                        "PX_Width": 10,
                        "MM_Width": 2,
                    },
                    "Metrics": {"TAD_MM": 5.0},
                },
            )
        ]

        rows = dhs_table_rows(records)
        assert len(rows) == 1
        row = rows[0]
        assert row["CaseID"] == "case1"
        assert row["FileName"] == "img1"
        assert row["Side"] == "Right"
        assert row["View"] == "AP"
        assert row["WEX"] == 50  # Wire entry x
        assert row["WTX"] == 150  # Wire tip x
        assert row["WWpx"] == 10
        assert row["WWmm"] == 2
        assert row["Analyst"] == "analyst1"

    def test_find_results_file_empty_dir(self, tmp_path):
        """Empty dir → default."""
        assert find_results_file(tmp_path) == tmp_path / "Results.json"

    def test_find_results_file_legacy(self, tmp_path):
        """Legacy file found."""
        legacy = tmp_path / "MyCase_Results.json"
        legacy.write_text("")
        assert find_results_file(tmp_path) == legacy

    def test_find_results_file_prefers_canonical(self, tmp_path):
        """Canonical name preferred over legacy."""
        legacy = tmp_path / "MyCase_Results.json"
        legacy.write_text("")
        default = tmp_path / "Results.json"
        default.write_text("")
        assert find_results_file(tmp_path) == default

    def test_find_results_file_example_case(self):
        """Locate example case legacy results file."""
        found = find_results_file(EXAMPLE_CASE_DIR)
        assert found.name == "Example_DICOM_Case_Results.json"
