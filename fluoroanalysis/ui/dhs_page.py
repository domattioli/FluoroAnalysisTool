"""DHS Tip-Apex Distance annotation page."""

from pathlib import Path

import numpy as np
import streamlit as st

from ..imaging.enhance import to_pil_rgb
from ..io.dicom import FluoroImage
from ..io.results import (
    FluoroRecord,
    load_results,
    parse_dhs_result,
    save_record,
    serialize_dhs_result,
)
from .annotation import capture_click, draw_overlays_dhs
from .state import DHS_WIDTH_PRESETS, get_dhs_state, make_dhs_procedure, reset_dhs_state


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
    """Render DHS annotation page."""
    state = get_dhs_state(file_key)

    # Preload from saved results if not already done
    preload_key = f"dhs_preloaded_{file_key}"
    if preload_key not in st.session_state:
        try:
            records = load_results(results_path)
            for rec in records:
                if rec.file_name == fluoro.file_name and "DHS" in rec.procedure:
                    parsed = parse_dhs_result(rec.result)
                    # Populate state from parsed result
                    if parsed.head is not None:
                        # Seed with 5 boundary points to reproduce ellipse
                        pts = parsed.head.boundary_points(5)
                        state.head_clicks = [(float(p[0]), float(p[1])) for p in pts]
                    if parsed.neck is not None:
                        state.neck_clicks = list(parsed.neck)
                    if parsed.wire.points and len(parsed.wire.points) >= 2:
                        state.wire_clicks = parsed.wire.points[:2]
                    if parsed.wire.width_px is not None:
                        state.width_px_override = parsed.wire.width_px
                    if parsed.wire.width_mm is not None:
                        state.width_mm = parsed.wire.width_mm
                    if rec.side in ("Left", "Right"):
                        state.side = rec.side
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
            "1 — Femoral head (click ≥5 boundary points)",
            "2 — Femoral neck (click 2 endpoints)",
            "3 — Wire centerline (click entry, then tip)",
            "4 — Wire width (click both edges)",
        ],
        horizontal=False,
        key=f"dhs_step_{file_key}",
    )

    step_index = ["1 — Femoral head (click ≥5 boundary points)",
                  "2 — Femoral neck (click 2 endpoints)",
                  "3 — Wire centerline (click entry, then tip)",
                  "4 — Wire width (click both edges)"].index(step)

    # Get current step click list
    step_lists = [state.head_clicks, state.neck_clicks, state.wire_clicks, state.width_clicks]
    current_list = step_lists[step_index]

    col1, col2 = st.columns([3, 1])

    with col1:
        # Controls row
        ctrl_col1, ctrl_col2, ctrl_col3 = st.columns(3)

        with ctrl_col1:
            side_key = f"dhs_side_{file_key}"
            if side_key not in st.session_state:
                st.session_state[side_key] = state.side if state.side in ("Left", "Right") else "Right"
            state.side = st.radio("Side", ["Left", "Right"], horizontal=True, key=side_key)

        with ctrl_col2:
            width_key = f"dhs_width_option_{file_key}"
            if width_key not in st.session_state:
                if state.width_mm in DHS_WIDTH_PRESETS:
                    st.session_state[width_key] = state.width_mm
                else:
                    st.session_state[width_key] = "Custom…"
            width_option = st.selectbox(
                "Wire width (mm)",
                list(DHS_WIDTH_PRESETS) + ["Custom…"],
                format_func=lambda x: str(x) if isinstance(x, float) else x,
                key=width_key,
            )
            if width_option == "Custom…":
                state.width_mm = st.number_input(
                    "Enter width (mm)",
                    value=state.width_mm or 2.5,
                    key=f"dhs_width_custom_{file_key}",
                )
            else:
                state.width_mm = float(width_option)

        with ctrl_col3:
            state.apex_flipped = st.checkbox(
                "Flip apex", value=state.apex_flipped, key=f"dhs_apex_flip_{file_key}"
            )

        # Button controls
        btn_col1, btn_col2, btn_col3 = st.columns(3)
        with btn_col1:
            if st.button("Undo last point", key=f"dhs_undo_{file_key}"):
                if current_list:
                    current_list.pop()
                    st.rerun()

        with btn_col2:
            if st.button("Clear step", key=f"dhs_clear_step_{file_key}"):
                current_list.clear()
                st.rerun()

        with btn_col3:
            if st.button("Clear all", key=f"dhs_clear_all_{file_key}"):
                reset_dhs_state(file_key)
                st.rerun()

        # Image annotation
        st.subheader("Click on the image to annotate")

        proc = make_dhs_procedure(state)
        overlaid_img = draw_overlays_dhs(to_pil_rgb(img8), state, proc)

        # Nonce for deduplication
        nonce_key = f"dhs_nonce_{file_key}"
        nonce = st.session_state.get(nonce_key, 0)

        click = capture_click(
            overlaid_img, display_width, key=f"dhs_{file_key}_{step_index}_{nonce}"
        )

        if click is not None:
            # Add click to appropriate list
            if step_index == 0:  # Head
                current_list.append(click)
            elif step_index == 1:  # Neck
                if len(current_list) >= 2:
                    st.toast("Neck already has 2 points — Undo or Clear")
                else:
                    current_list.append(click)
            elif step_index == 2:  # Wire
                if len(current_list) >= 2:
                    st.toast("Wire already has 2 points — Undo or Clear")
                else:
                    current_list.append(click)
            elif step_index == 3:  # Width
                if len(current_list) >= 2:
                    st.toast("Width already has 2 points — Undo or Clear")
                else:
                    current_list.append(click)

            st.session_state[nonce_key] = nonce + 1
            st.rerun()

    with col2:
        st.subheader("Metrics")

        if proc.ready():
            try:
                metrics = proc.evaluate()
                if metrics.tad_mm is not None:
                    st.metric("TAD (mm)", f"{metrics.tad_mm:.2f}")
                else:
                    st.metric("TAD (px)", f"{metrics.tad_px:.2f}")

                st.metric("Angle (deg)", f"{metrics.angle_deg:.2f}")

                if metrics.px_per_mm is not None:
                    st.metric("px per mm", f"{metrics.px_per_mm:.2f}")

                for warning in metrics.warnings:
                    st.warning(warning)
            except ValueError as e:
                st.error(f"Error computing metrics: {e}")
        else:
            st.info("Progress")
            checked = [
                len(state.head_clicks) >= 3,
                len(state.neck_clicks) >= 2,
                len(state.wire_clicks) >= 2,
                len(state.width_clicks) >= 2,
            ]
            for i, done in enumerate(checked):
                status = "✅" if done else "⬜"
                st.write(f"{status} Step {i + 1}")

        # Save button
        save_enabled = proc.ready() or (state.head_clicks and state.neck_clicks)
        if st.button("Save result", disabled=not save_enabled, key=f"dhs_save_{file_key}"):
            record = FluoroRecord(
                case_id=fluoro.case_id,
                file_name=fluoro.file_name,
                surgeon=fluoro.surgeon,
                date_time_stamp=fluoro.acquired_at,
                view=view,
                procedure="DHS Tip-Apex Distance",
                result=serialize_dhs_result(proc.to_result_data()),
                side=state.side,
                tag=tag,
                user=analyst,
            )
            save_record(results_path, record)
            st.success(f"Saved to {results_path}")
