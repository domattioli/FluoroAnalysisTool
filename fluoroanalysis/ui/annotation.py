"""Image annotation canvas with click capture."""

import streamlit as st
from PIL import Image, ImageDraw
from streamlit_image_coordinates import streamlit_image_coordinates

from .state import PSHF_WIRE_COLORS, DHSState, PSHFState


def capture_click(
    pil_img: Image.Image, display_width: int, key: str
) -> tuple[float, float] | None:
    """
    Capture click on resized image using streamlit_image_coordinates.

    Deduplicates clicks to avoid replay on rerun. Returns image-space coordinates
    (original resolution) or None if no new click.
    """
    orig_w, orig_h = pil_img.size

    # Resize to display width, maintaining aspect ratio
    scale = display_width / orig_w
    new_h = int(orig_h * scale)
    resized = pil_img.resize((display_width, new_h), Image.Resampling.LANCZOS)

    # Capture click
    click_data = streamlit_image_coordinates(resized, key=key)

    if click_data is None:
        return None

    # Deduplicate: check if this is a new click
    last_click_key = f"_last_click_{key}"
    last_click = st.session_state.get(last_click_key)

    current_click = (click_data["x"], click_data["y"])
    if last_click == current_click:
        # Same click as before, ignore
        return None

    # Store and return
    st.session_state[last_click_key] = current_click

    # Convert to original image coordinates
    img_x = current_click[0] * orig_w / display_width
    img_y = current_click[1] * orig_h / new_h

    return (img_x, img_y)


def draw_overlays_dhs(
    pil_img: Image.Image, state: DHSState, proc
) -> Image.Image:
    """Draw DHS annotations on image copy."""
    img_copy = pil_img.copy()
    draw = ImageDraw.Draw(img_copy)
    w, h = img_copy.size
    dot_radius = max(2, round(w / 200))
    line_width = max(2, round(w / 400))

    # Head clicks as cyan dots
    for p in state.head_clicks:
        x, y = p
        draw.ellipse(
            [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
            outline="cyan",
            width=line_width,
        )

    # Fitted head ellipse boundary (yellow)
    if proc.head is not None:
        boundary_pts = proc.head.boundary_points(200)
        boundary_list = [(float(p[0]), float(p[1])) for p in boundary_pts]
        if len(boundary_list) > 1:
            draw.polygon(boundary_list, outline="yellow")

    # Neck line (green)
    if len(state.neck_clicks) >= 2:
        draw.line(
            [state.neck_clicks[0], state.neck_clicks[1]], fill="green", width=line_width
        )
        # Endpoints
        for p in state.neck_clicks[:2]:
            x, y = p
            draw.ellipse(
                [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                outline="green",
                width=line_width,
            )

    # Bisector (magenta) and apex marker (red)
    if proc.bisector() is not None:
        bis = proc.bisector()
        draw.line([bis[0], bis[1]], fill="magenta", width=line_width)

        # Apex as red circle + cross
        apex = bis[0]
        ax, ay = apex
        apex_radius = max(4, round(w / 150))
        draw.ellipse(
            [ax - apex_radius, ay - apex_radius, ax + apex_radius, ay + apex_radius],
            outline="red",
            width=line_width,
        )
        # Cross
        cross_size = apex_radius + 2
        draw.line([ax - cross_size, ay, ax + cross_size, ay], fill="red", width=line_width)
        draw.line([ax, ay - cross_size, ax, ay + cross_size], fill="red", width=line_width)

    # Wire (orange line)
    if len(state.wire_clicks) >= 2:
        draw.line(state.wire_clicks[:2], fill="orange", width=line_width)
        # Endpoints
        for i, p in enumerate(state.wire_clicks[:2]):
            x, y = p
            if i == 1:  # Tip
                # Filled dot
                draw.ellipse(
                    [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                    fill="orange",
                )
            else:
                draw.ellipse(
                    [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                    outline="orange",
                    width=line_width,
                )

    # Width clicks (white dots + line)
    if len(state.width_clicks) >= 2:
        draw.line(state.width_clicks[:2], fill="white", width=line_width)
        for p in state.width_clicks[:2]:
            x, y = p
            draw.ellipse(
                [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                outline="white",
                width=line_width,
            )

    return img_copy


def draw_overlays_pshf(pil_img: Image.Image, state: PSHFState, metrics_or_none) -> Image.Image:
    """Draw PSHF annotations on image copy."""
    img_copy = pil_img.copy()
    draw = ImageDraw.Draw(img_copy)
    w, h = img_copy.size
    dot_radius = max(2, round(w / 200))
    line_width = max(2, round(w / 400))

    # Fracture line (red)
    if len(state.fracture_clicks) >= 2:
        draw.line(state.fracture_clicks[:2], fill="red", width=line_width)
        for p in state.fracture_clicks[:2]:
            x, y = p
            draw.ellipse(
                [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                outline="red",
                width=line_width,
            )

    # Wires with colors
    for i in range(min(3, len(state.wires))):
        if len(state.wires[i]) >= 2:
            color = PSHF_WIRE_COLORS[i]
            # Polyline
            draw.line(state.wires[i], fill=color, width=line_width)
            # First point (tip) emphasized
            tip = state.wires[i][0]
            x, y = tip
            draw.ellipse(
                [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
                fill=color,
            )

    # Intersections (white dots) if metrics provided
    if metrics_or_none is not None and hasattr(metrics_or_none, "intersections"):
        intersection_radius = max(3, round(w / 150))
        for inter in metrics_or_none.intersections:
            if inter is not None:
                x, y = inter
                draw.ellipse(
                    [
                        x - intersection_radius,
                        y - intersection_radius,
                        x + intersection_radius,
                        y + intersection_radius,
                    ],
                    outline="white",
                    width=line_width,
                )

    return img_copy
