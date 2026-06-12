"""PSHF (Pediatric Supracondylar Humerus Fracture) annotation page."""

from pathlib import Path

import numpy as np
import pandas as pd
import streamlit as st

from ..imaging.enhance import to_pil_rgb
from ..io.dicom import FluoroImage
from ..io.results import (
    FluoroRecord,
    load_results,
    parse_pshf_result,
    save_record,
    serialize_pshf_result,
)
from .annotation import capture_click, draw_overlays_pshf
from .state import get_pshf_state, make_pshf_procedure, reset_pshf_state


def render(
    fluoro: FluoroImage,
    img8: "np.ndarray",  # uint8 image after window/level
    display_width: int,
    file_key: str,
    results_path: Path,
    analyst: str,
    view: str,
    tag: str,
) -> None:
    """Render PSHF annotation page."""
    state = get_pshf_state(file_key)

    # Preload from saved results if not already done
    preload_key = f"pshf_preloaded_{file_key}"
    if preload_key not in st.session_state:
        try:
            records = load_results(results_path)
            for rec in records:
                if rec.file_name == fluoro.file_name and "Pediatric" in rec.procedure:
                    parsed = parse_pshf_result(rec.result)
                    # Populate state from parsed result
                    if parsed.fracture is not None:
                        state.fracture_clicks = list(parsed.fracture)
                    for i, wire in enumerate(parsed.wires):
                        if i < 3 and wire.points:
                            state.wires[i] = list(wire.points)
                        if i < 3 and wire.width_mm is not None:
                            state.widths_mm[i] = wire.width_mm
                    st.session_state[preload_key] = True
                    break
        except Exception:
            pass
        if preload_key not in st.session_state:
            st.session_state[preload_key] = True

    # Step radio
    step = st.radio(
        "Annotation step",
        [
            "1 — Fracture line (2 clicks)",
            "2 — Wire 1 (≥2 clicks along centerline, tip first)",
            "3 — Wire 2",
            "4 — Wire 3 (optional on lateral)",
        ],
        horizontal=False,
        key=f"pshf_step_{file_key}",
    )

    step_index = [
        "1 — Fracture line (2 clicks)",
        "2 — Wire 1 (≥2 clicks along centerline, tip first)",
        "3 — Wire 2",
        "4 — Wire 3 (optional on lateral)",
    ].index(step)

    # Get current step click list
    if step_index == 0:
        current_list = state.fracture_clicks
    else:
        current_list = state.wires[step_index - 1]

    col1, col2 = st.columns([3, 1])

    with col1:
        # Button controls
        btn_col1, btn_col2, btn_col3 = st.columns(3)
        with btn_col1:
            if st.button("Undo last point", key=f"pshf_undo_{file_key}"):
                if current_list:
                    current_list.pop()
                    st.rerun()

        with btn_col2:
            if st.button("Clear step", key=f"pshf_clear_step_{file_key}"):
                current_list.clear()
                st.rerun()

        with btn_col3:
            if st.button("Clear all", key=f"pshf_clear_all_{file_key}"):
                reset_pshf_state(file_key)
                st.rerun()

        # Image annotation
        st.subheader("Click on the image to annotate")

        proc = make_pshf_procedure(state)
        metrics_for_overlay = None
        if proc.ready():
            try:
                metrics_for_overlay = proc.evaluate()
            except ValueError:
                pass

        overlaid_img = draw_overlays_pshf(to_pil_rgb(img8), state, metrics_for_overlay)

        # Nonce for deduplication
        nonce_key = f"pshf_nonce_{file_key}"
        nonce = st.session_state.get(nonce_key, 0)

        click = capture_click(
            overlaid_img, display_width, key=f"pshf_{file_key}_{step_index}_{nonce}"
        )

        if click is not None:
            # Add click to appropriate list
            if step_index == 0:  # Fracture
                if len(current_list) >= 2:
                    st.toast("Fracture already has 2 points — Undo or Clear")
                else:
                    current_list.append(click)
            else:  # Wires
                current_list.append(click)

            st.session_state[nonce_key] = nonce + 1
            st.rerun()

    with col2:
        st.subheader("Metrics")

        if proc.ready():
            try:
                metrics = proc.evaluate()

                st.metric("Fracture width (px)", f"{metrics.fracture_width_px:.2f}")

                if metrics.breadth_ratio is not None:
                    st.metric("Breadth ratio", f"{metrics.breadth_ratio:.2f}")

                if metrics.spacing_ratio is not None:
                    st.metric("Spacing ratio", f"{metrics.spacing_ratio:.2f}")

                if metrics.angles_deg:
                    st.subheader("Angles (degrees)")
                    angles_df = pd.DataFrame(
                        [
                            {"Pair": k, "Angle": f"{v:.2f}"}
                            for k, v in metrics.angles_deg.items()
                        ]
                    )
                    st.dataframe(angles_df, width="stretch", hide_index=True)

                for warning in metrics.warnings:
                    st.warning(warning)

            except ValueError as e:
                st.error(f"Error computing metrics: {e}")
        else:
            st.info("Progress")
            checked = [
                len(state.fracture_clicks) >= 2,
                len(state.wires[0]) >= 2,
                len(state.wires[1]) >= 2,
            ]
            for i, done in enumerate(checked):
                status = "✅" if done else "⬜"
                st.write(f"{status} Step {i + 1}")

        st.caption("Lateral views may use only 2 wires")

        # Save button
        save_enabled = proc.ready() or (state.fracture_clicks and state.wires[0])
        if st.button("Save result", disabled=not save_enabled, key=f"pshf_save_{file_key}"):
            record = FluoroRecord(
                case_id=fluoro.case_id,
                file_name=fluoro.file_name,
                surgeon=fluoro.surgeon,
                date_time_stamp=fluoro.acquired_at,
                view=view,
                procedure="Pediatric Supracondylar Humerus Fracture",
                result=serialize_pshf_result(proc.to_result_data()),
                side="",
                tag=tag,
                user=analyst,
            )
            save_record(results_path, record)
            st.success(f"Saved to {results_path}")
