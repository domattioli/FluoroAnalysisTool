"""FluoroAnalysisTool Streamlit app entry point."""

import tempfile
from pathlib import Path

import streamlit as st

from fluoroanalysis import __version__

from ..imaging.enhance import histogram_equalize, invert, to_uint8
from ..io.dicom import FluoroImage, list_case_files, load_dicom
from ..io.results import find_results_file, load_results
from . import dhs_page, pshf_page, results_page


def main() -> None:
    """Main Streamlit app."""
    st.set_page_config(
        page_title="FluoroAnalysisTool",
        page_icon="🦴",
        layout="wide",
    )

    st.title("FluoroAnalysisTool")
    st.caption("Fluoroscopic image annotation for surgical metrics")

    # Sidebar: case source selection
    st.sidebar.header("Case Source")

    case_source = st.sidebar.radio(
        "Select source",
        ["Example case", "Upload DICOMs", "Local folder"],
        key="case_source",
    )

    case_dir = None

    if case_source == "Example case":
        # Use bundled example
        example_path = (
            Path(__file__).resolve().parent.parent.parent / "data" / "Example_DICOM_Case"
        )
        if example_path.exists():
            case_dir = str(example_path)
        else:
            st.sidebar.error(f"Example case not found at {example_path}")

    elif case_source == "Upload DICOMs":
        # File uploader
        uploaded_files = st.sidebar.file_uploader(
            "Choose DICOM files",
            type=["dcm"],
            accept_multiple_files=True,
            key="dicom_uploader",
        )

        if uploaded_files:
            # Create temp dir for uploads
            if "upload_temp_dir" not in st.session_state:
                st.session_state.upload_temp_dir = tempfile.mkdtemp()

            temp_dir = Path(st.session_state.upload_temp_dir)
            temp_dir.mkdir(parents=True, exist_ok=True)

            for uploaded_file in uploaded_files:
                file_path = temp_dir / uploaded_file.name
                if not file_path.exists():
                    file_path.write_bytes(uploaded_file.getbuffer())

            case_dir = str(temp_dir)

    else:  # Local folder
        folder_path = st.sidebar.text_input(
            "Enter folder path",
            key="local_folder",
        )
        if folder_path:
            folder = Path(folder_path)
            if folder.exists() and folder.is_dir():
                case_dir = str(folder)
            else:
                st.sidebar.error("Invalid folder path")

    # No case selected
    if case_dir is None:
        st.info("Select a case source in the sidebar to begin.")
        return

    # List files
    try:
        files = list_case_files(case_dir)
    except Exception as e:
        st.error(f"Error listing files: {e}")
        return

    if not files:
        st.warning("No DICOM files found in the selected directory.")
        return

    # File selector
    st.sidebar.subheader("DICOM Files")
    file_stems = [f.stem for f in files]

    # Load results to mark annotated files
    results_path = find_results_file(case_dir)
    annotated_files = set()
    try:
        records = load_results(results_path)
        annotated_files = {r.file_name for r in records}
    except Exception:
        pass

    # Format file labels
    def format_file_label(stem: str) -> str:
        if stem in annotated_files:
            return f"✅ {stem}"
        return stem

    selected_stem = st.sidebar.selectbox(
        "Select DICOM",
        file_stems,
        format_func=format_file_label,
        key="selected_file",
    )

    selected_file = files[file_stems.index(selected_stem)]
    file_key = str(selected_file)

    # Load image
    @st.cache_resource
    def load_and_cache(path_str: str) -> FluoroImage:
        return load_dicom(path_str)

    fluoro = load_and_cache(str(selected_file))

    # Image controls
    with st.sidebar.expander("Image controls", expanded=True):
        pixels = fluoro.pixels
        pixel_min, pixel_max = float(pixels.min()), float(pixels.max())

        # Window center and width
        wc_default = fluoro.window_center or (pixel_min + pixel_max) / 2
        ww_default = fluoro.window_width or (pixel_max - pixel_min)

        window_center = st.slider(
            "Window center",
            min_value=pixel_min,
            max_value=pixel_max,
            value=wc_default,
            key="window_center",
        )
        window_width = st.slider(
            "Window width",
            min_value=1.0,
            max_value=pixel_max - pixel_min,
            value=ww_default,
            key="window_width",
        )

        # Enhancement options
        histogram_eq = st.checkbox("Histogram equalize", key="histogram_eq")
        invert_img = st.checkbox("Invert", key="invert_img")

        # Display width
        display_width = st.slider(
            "Display width (px)",
            min_value=400,
            max_value=1200,
            value=800,
            key="display_width",
        )

    # Analyst and view info
    st.sidebar.subheader("Annotation Info")
    analyst = st.sidebar.text_input(
        "Analyst name",
        value=st.session_state.get("analyst", ""),
        key="analyst_input",
    )
    st.session_state.analyst = analyst

    view = st.sidebar.radio(
        "View",
        ["AP", "Lateral"],
        horizontal=True,
        key="view_radio",
    )
    st.session_state.view = view

    # Prepare image
    img8 = to_uint8(fluoro.pixels, window_center, window_width)
    if histogram_eq:
        img8 = histogram_equalize(img8)
    if invert_img:
        img8 = invert(img8)

    tag = f"Fluoro: {file_stems.index(selected_stem) + 1}"

    # Main tabs
    tab1, tab2, tab3, tab4 = st.tabs(
        ["DHS Tip-Apex Distance", "PSHF", "Results", "About"]
    )

    with tab1:
        dhs_page.render(
            fluoro,
            img8,
            display_width,
            file_key,
            results_path,
            analyst,
            view,
            tag,
        )

    with tab2:
        pshf_page.render(
            fluoro,
            img8,
            display_width,
            file_key,
            results_path,
            analyst,
            view,
            tag,
        )

    with tab3:
        results_page.render(results_path, case_dir)

    with tab4:
        st.markdown(
            """
## About FluoroAnalysisTool

This tool annotates orthopedic fluoroscopy DICOMs for surgical metric analysis.

### Supported Procedures
- **DHS Tip-Apex Distance**: Measure tip-to-apex distance on dynamic hip screw fixations
- **Pediatric Supracondylar Humerus Fracture (PSHF)**: Analyze wire positioning and fracture geometry

### Quick Start
1. Load a case from the sidebar
2. Select a DICOM file
3. Choose a procedure tab
4. Follow the on-screen steps to click points
5. Save results when complete

### Results
All annotations are saved to `Results.json` in the case directory, compatible with legacy MATLAB format.

### PHI Notice
⚠️ **De-identify DICOMs before uploading to a hosted instance.**

### Documentation
See [Python Port Plan](https://github.com/domattioli/FluoroAnalysisTool/blob/main/doc/PYTHON_PORT_PLAN.md)
for detailed specifications.
            """
        )

    # Footer
    st.divider()
    st.caption(f"FluoroAnalysisTool v{__version__}")


if __name__ == "__main__":
    main()
