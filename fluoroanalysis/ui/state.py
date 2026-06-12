"""Typed session state accessors for Streamlit."""

from dataclasses import dataclass, field

import streamlit as st

from ..geometry.ellipse import fit_ellipse_axis_aligned
from ..geometry.primitives import Point, distance
from ..io.results import WireAnnotation
from ..procedures.dhs import DHSProcedure
from ..procedures.pshf import PSHFProcedure

DHS_WIDTH_PRESETS = (1.5, 2.5, 3.2)
PSHF_WIRE_COLORS = ("#FF7F50", "#FFA500", "#FF4500")


@dataclass
class DHSState:
    """DHS procedure annotation state."""

    head_clicks: list[Point] = field(default_factory=list)
    neck_clicks: list[Point] = field(default_factory=list)
    wire_clicks: list[Point] = field(default_factory=list)
    width_clicks: list[Point] = field(default_factory=list)
    width_mm: float | None = 2.5
    apex_flipped: bool = False
    side: str = "Right"
    width_px_override: float | None = None


@dataclass
class PSHFState:
    """PSHF procedure annotation state."""

    fracture_clicks: list[Point] = field(default_factory=list)
    wires: list[list[Point]] = field(default_factory=lambda: [[], [], []])
    widths_mm: list[float | None] = field(default_factory=lambda: [None, None, None])


def get_dhs_state(file_key: str) -> DHSState:
    """Get or create DHS state for a file, stored in session_state."""
    if "dhs_states" not in st.session_state:
        st.session_state.dhs_states = {}

    if file_key not in st.session_state.dhs_states:
        st.session_state.dhs_states[file_key] = DHSState()

    return st.session_state.dhs_states[file_key]


def get_pshf_state(file_key: str) -> PSHFState:
    """Get or create PSHF state for a file, stored in session_state."""
    if "pshf_states" not in st.session_state:
        st.session_state.pshf_states = {}

    if file_key not in st.session_state.pshf_states:
        st.session_state.pshf_states[file_key] = PSHFState()

    return st.session_state.pshf_states[file_key]


def reset_dhs_state(file_key: str) -> None:
    """Reset DHS state for a file."""
    if "dhs_states" in st.session_state and file_key in st.session_state.dhs_states:
        st.session_state.dhs_states[file_key] = DHSState()


def reset_pshf_state(file_key: str) -> None:
    """Reset PSHF state for a file."""
    if "pshf_states" in st.session_state and file_key in st.session_state.pshf_states:
        st.session_state.pshf_states[file_key] = PSHFState()


def make_dhs_procedure(s: DHSState) -> DHSProcedure:
    """Build DHSProcedure from state, handling partial annotations."""
    head = None
    if len(s.head_clicks) >= 3:
        try:
            head = fit_ellipse_axis_aligned(s.head_clicks)
        except ValueError:
            head = None

    neck = None
    if len(s.neck_clicks) >= 2:
        neck = (s.neck_clicks[0], s.neck_clicks[1])

    wire = None
    if len(s.wire_clicks) >= 2:
        wire = (s.wire_clicks[0], s.wire_clicks[1])

    wire_width_px = None
    if len(s.width_clicks) >= 2:
        wire_width_px = distance(s.width_clicks[0], s.width_clicks[1])
    elif s.width_px_override is not None:
        wire_width_px = s.width_px_override

    return DHSProcedure(
        head=head,
        neck=neck,
        apex_flipped=s.apex_flipped,
        wire=wire,
        wire_width_px=wire_width_px,
        wire_width_mm=s.width_mm,
        side=s.side,
    )


def make_pshf_procedure(s: PSHFState) -> PSHFProcedure:
    """Build PSHFProcedure from state."""
    fracture = None
    if len(s.fracture_clicks) >= 2:
        fracture = (s.fracture_clicks[0], s.fracture_clicks[1])

    wires = []
    for i in range(min(3, len(s.wires))):
        if len(s.wires[i]) >= 2:
            wires.append(
                WireAnnotation(
                    points=s.wires[i],
                    width_mm=s.widths_mm[i] if i < len(s.widths_mm) else None,
                )
            )

    return PSHFProcedure(
        fracture=fracture,
        wires=wires,
    )
