"""Results table and download page."""

from pathlib import Path

import pandas as pd
import streamlit as st

from ..geometry.primitives import distance
from ..io.results import delete_record, dhs_table_rows, load_results, parse_pshf_result


def render(results_path: Path, case_dir: str) -> None:
    """Render results summary and download page."""
    if not results_path.exists():
        st.info("No results file found yet. Annotate some images to create it.")
        return

    records = load_results(results_path)

    if not records:
        st.info("Results file exists but is empty.")
        return

    # Header statistics
    st.subheader("Summary")
    total_records = len(records)
    dhs_count = sum(1 for r in records if "DHS" in r.procedure)
    pshf_count = sum(1 for r in records if "Pediatric" in r.procedure)

    col1, col2, col3 = st.columns(3)
    col1.metric("Total records", total_records)
    col2.metric("DHS records", dhs_count)
    col3.metric("PSHF records", pshf_count)

    st.divider()

    # DHS table
    if dhs_count > 0:
        st.subheader("DHS Results")
        dhs_rows = dhs_table_rows(records)
        dhs_df = pd.DataFrame(dhs_rows)
        st.dataframe(dhs_df, width="stretch", hide_index=True)

        csv_data = dhs_df.to_csv(index=False)
        st.download_button(
            label="Download DHS as CSV",
            data=csv_data,
            file_name="DHS_results.csv",
            mime="text/csv",
            key="dhs_csv_download",
        )

    st.divider()

    # PSHF table
    pshf_rows = []
    for rec in records:
        if "Pediatric" not in rec.procedure:
            continue

        parsed = parse_pshf_result(rec.result)
        analyst = rec.user if rec.user else rec.surgeon

        fracture_width = None
        if parsed.fracture:
            fracture_width = distance(parsed.fracture[0], parsed.fracture[1])

        breadth_ratio = parsed.metrics.get("Breadth_Ratio") if parsed.metrics else None
        spacing_ratio = parsed.metrics.get("Spacing_Ratio") if parsed.metrics else None

        pshf_rows.append(
            {
                "FileName": rec.file_name,
                "View": rec.view,
                "Fracture_Width_PX": fracture_width,
                "Breadth_Ratio": breadth_ratio,
                "Spacing_Ratio": spacing_ratio,
                "Analyst": analyst,
            }
        )

    if pshf_rows:
        st.subheader("PSHF Results")
        pshf_df = pd.DataFrame(pshf_rows)
        st.dataframe(pshf_df, width="stretch", hide_index=True)

        csv_data = pshf_df.to_csv(index=False)
        st.download_button(
            label="Download PSHF as CSV",
            data=csv_data,
            file_name="PSHF_results.csv",
            mime="text/csv",
            key="pshf_csv_download",
        )

    st.divider()

    # Raw download
    results_bytes = results_path.read_bytes()
    st.download_button(
        label="Download full Results.json",
        data=results_bytes,
        file_name="Results.json",
        mime="application/json",
        key="raw_download",
    )

    st.divider()

    # Per-record details
    st.subheader("Record Details")
    for i, rec in enumerate(records):
        with st.expander(f"{rec.file_name} ({rec.procedure})"):
            col1, col2 = st.columns(2)
            with col1:
                st.json(rec.to_json_dict())
            with col2:
                if st.button(
                    "Delete record",
                    key=f"delete_record_{i}",
                    type="secondary",
                ):
                    delete_record(results_path, rec.file_name)
                    st.success(f"Deleted {rec.file_name}")
                    st.rerun()
