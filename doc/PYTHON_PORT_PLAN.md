# FluoroAnalysisTool — Python + Streamlit Port Plan

**Status:** Phase 0–2 implemented in this branch. Phase 3 tracked below.
**Date:** 2026-06-12

---

## 1. Why port

The existing tool is a MATLAB R2018a handle-graphics GUI (`src/00-Startup/main.m`) for
annotating orthopedic fluoroscopy (DICOM) and computing surgical metrics:

- **DHS Tip-Apex Distance** — femoral head ellipse + femoral neck line + guide-wire
  annotation → tip-apex distance (TAD) with magnification correction calibrated by the
  known wire width.
- **PSHF (Pediatric Supracondylar Humerus Fracture)** — fracture line + up to 3 K-wires
  → pin-spread / breadth ratios, wire–fracture intersections, inter-wire angles.

Pain points found in the audit of the MATLAB code base:

| Problem | Evidence |
| --- | --- |
| Requires a MATLAB license + specific release | README: "May not work on earlier versions!" |
| Windows-only hardcoded paths | `Z:\`, `D:\`, `R:\`, OneDrive paths across `src/01-Data_Management` |
| Dead / broken code paths | `getFemoralHead.m` (code "erroneously deleted"), `identifySideDHS.m` (empty stub), `DHS.asv` autosave artifacts |
| Fragile interaction model | "clicking more than 2 points may cause an error… worst case, restart the tool" (README) |
| Abandoned ML socket integration | MATLAB↔Python TCP socket disabled since Sept 2020; TensorFlow 1.14 pins |
| No tests, no CI | zero automated checks on the geometry that produces clinical metrics |
| Fragile results I/O | line-indexed `Results.json` (JSON-lines, position-coupled to directory listing) |

A Python + Streamlit port removes the license barrier, runs in any browser (hostable on
Streamlit Community Cloud or any container host), and lets the measurement math live in a
tested, UI-independent library.

## 2. Target architecture

```
FluoroAnalysisTool/
├── pyproject.toml               # package metadata, deps, ruff + pytest config
├── streamlit_app.py             # entry point (Streamlit Cloud auto-detects this)
├── fluoroanalysis/              # pure-Python library — no Streamlit imports
│   ├── geometry/
│   │   ├── primitives.py        # points, segments, slopes, distances, polyline ops
│   │   ├── ellipse.py           # axis-aligned ellipse model, fit, line intersection
│   │   └── intersections.py     # segment–segment / polyline–segment intersection
│   ├── imaging/
│   │   └── enhance.py           # window/level, histogram equalization, invert, to-8-bit
│   ├── io/
│   │   ├── dicom.py             # pydicom load, metadata extraction, de-identification
│   │   └── results.py           # results schema + JSON-lines store (legacy-compatible)
│   └── procedures/
│       ├── base.py              # Procedure protocol: ready / evaluate / serialize
│       ├── dhs.py               # TAD computation (port of @DHS/DHS.m evaluate())
│       └── pshf.py              # pin-spread computation (port of @PSHF/PSHF.m evaluate())
├── fluoroanalysis/ui/           # Streamlit layer (imports the library, never vice versa)
│   ├── state.py                 # typed session-state accessors
│   ├── annotation.py            # click-capture canvas + overlay rendering
│   ├── dhs_page.py              # DHS workflow page
│   ├── pshf_page.py             # PSHF workflow page
│   └── results_page.py          # results browser / CSV export
├── tests/                       # pytest — geometry, procedures, io round-trips
└── .github/workflows/python-ci.yml
```

Design rules:

1. **UI/logic split.** All clinically meaningful math lives in `fluoroanalysis/` with unit
   tests pinned to hand-computed values. The Streamlit layer only collects clicks and
   renders results. (The MATLAB version interleaved math with `UserData` plumbing.)
2. **Backward-compatible results.** `io/results.py` reads both legacy schema variants
   observed in `data/Example_DICOM_Case/Example_DICOM_Case_Results.json`
   (`Femoral_Neck` as a bare 2×2 array *and* as `{Neck_XY, Bisector_XY}`) and writes the
   modern explicit schema. One JSON object per line is preserved, but records are keyed
   by `FileName` instead of line position.
3. **No hardcoded paths.** Input via directory path (local run) or file upload (hosted
   run); bundled example case for instant demo.
4. **Stateless math, explicit state.** Annotation state is a serializable dataclass in
   `st.session_state`; every step has Undo/Reset.

## 3. Algorithm ports (traceability to MATLAB)

| Python | MATLAB source | Notes |
| --- | --- | --- |
| `geometry/ellipse.py: Ellipse` | `equationOfEllipse.m`, `generateEllipsePoints.m`, `simplifyEllipse.m` | axis-aligned ellipse `((x-h)/a)² + ((y-k)/b)² = 1`; keeps legacy `Left_XY/Top_XY/Center_XY` serialization |
| `geometry/ellipse.py: fit_ellipse_axis_aligned` | (new) replaces interactive `imellipse` | least-squares fit from ≥4 clicked boundary points; ≥3 falls back to circle fit |
| `geometry/primitives.py: perpendicular_bisector` | `femoralNeckPerpendicularBisectorXY.m` | midpoint + slope `-1/m`, extended to ellipse intersections; vertical/horizontal neck handled explicitly (MATLAB divides by zero) |
| `procedures/dhs.py: DHSProcedure.evaluate` | `@DHS/DHS.m` `evaluate()` | `TAD_px = ‖tip − apex‖`; `TAD_mm = TAD_px / (wire_px / wire_mm)`; `θ = |atan(m_wire) − atan(m_bisector)|` |
| `procedures/pshf.py: PSHFProcedure.evaluate` | `@PSHF/PSHF.m` `evaluate()`, `computePinSpreadRatio.m` | wire–fracture intersections (InterX → shapely-free segment intersection), `ratio = max pairwise breadth / fracture width`, spacing, pairwise wire angles |
| `io/results.py` | `writeResult.m`, `retrieveResults.m`, `saveRoutine.m`, `json2TableDHS.m` | JSON-lines store + CSV table export (`WEX, WEY, WTX, WTY, WWpx, WWmm, TAX, TAY…`) |
| `io/dicom.py: deidentify` | `deIdentifyDICOM.m` | blanks patient identity tags; extended tag list vs. MATLAB (which only cleared `PatientName`) |
| `imaging/enhance.py` | `histeq` usage in `displayWatchSurgery.m`, `estimateWireWidth.m` | window/level from DICOM tags + manual override |

Constants preserved: DHS implant width presets **1.5 / 2.5 / 3.2 mm** (+ custom), mm→inch
`1/25.4`, PSHF wire colors coral/orange/orange-red.

Known MATLAB quirks **fixed, not ported**:

- `Center_XY = (Top_x, Left_y)` was only valid for axis-aligned ellipses drawn by
  `imellipse`; the port computes the true fitted center and writes the legacy triplet
  from the fitted model (round-trip compatible).
- Vertical femoral neck (`Δx = 0`) crashed the bisector slope computation; handled.
- Wire slope used `abs()` on both slopes before subtracting angles, which folds sign
  errors for steep wires; the port uses `atan2`-based unsigned angle between direction
  vectors, equal to the MATLAB value in all non-degenerate cases and correct in the
  degenerate ones.
- Legacy writer indexed records by line number == directory listing position → silently
  corrupted results when files were added/removed (acknowledged in commit fd0a1e4); port
  keys records by `FileName`.

## 4. Streamlit UX

- **Sidebar:** case loader (bundled example / upload `.dcm` files / local directory),
  file list with annotated-state badges, analyst name, procedure picker.
- **Main panel:** image viewer (window/level, histogram-equalize, invert, zoom-to-width)
  with click annotation via `streamlit-image-coordinates`; overlays rendered
  server-side with Pillow so what you see is exactly what is measured.
- **Step state machine per procedure** with per-step instructions, point counters,
  Undo last point / Restart step buttons — replaces the crash-prone
  "right-click to confirm, don't click 3 points" MATLAB flow.
- **DHS page:** side → head ellipse (≥5 boundary clicks) → neck line (2 clicks, bisector
  auto-drawn, flippable) → wire (2 clicks base→tip) → width (2 edge clicks + mm preset)
  → live TAD card with the >25 mm cut-out risk flag (Baumgaertner).
- **PSHF page:** fracture line (2 clicks) → wires 1–3 (polyline + Done) → live breadth
  ratio / spacing / angles; lateral-view 2-wire mode supported (per README workflow).
- **Results page:** all saved records, per-case table, CSV download
  (`json2TableDHS`-compatible columns), JSON-lines download, legacy-file import.

## 5. Testing & CI

- `tests/test_geometry.py` — ellipse fit/intersection, bisector, segment intersection
  against hand-computed values.
- `tests/test_dhs.py` — TAD on synthetic configurations with known answers (incl.
  magnification correction and angle).
- `tests/test_pshf.py` — pin-spread ratios on synthetic 3-wire configurations.
- `tests/test_results_io.py` — legacy `Example_DICOM_Case_Results.json` parses; modern
  round-trip; CSV export columns.
- `tests/test_dicom.py` — bundled example DICOMs load; de-identification blanks tags.
- CI: `python-ci.yml` → ruff + pytest on 3.11/3.12.

## 6. Deployment

- **Streamlit Community Cloud:** point the app at `streamlit_app.py`, Python 3.11+,
  deps resolve from `pyproject.toml` (or `requirements.txt` mirror). Uploaded PHI never
  persists server-side beyond the session; de-identify before upload regardless.
- **Local:** `pip install -e . && streamlit run streamlit_app.py`.
- **Container:** trivial `python:3.11-slim` + `pip install .` + `streamlit run`.

## 7. Phases

| Phase | Scope | Status |
| --- | --- | --- |
| 0 | Package scaffold, pyproject, CI, test harness | ✅ this branch |
| 1 | Core library: geometry, imaging, io, DHS + PSHF procedures, tests | ✅ this branch |
| 2 | Streamlit app: viewer, DHS + PSHF workflows, results browser/export | ✅ this branch |
| 3a | Auto wire-width estimation (Canny edge port of `estimateWireWidth.m`, scikit-image) | ☐ follow-up |
| 3b | Combined AP+lateral TAD per case (true Baumgaertner TAD) | ☐ follow-up |
| 3c | Mask Objects + Watch Surgery (cine) procedure ports | ☐ follow-up |
| 3d | ML-assisted wire detection (replaces dead MATLAB↔Python socket; runs in-process) | ☐ follow-up |
| 3e | Retire MATLAB tree to `legacy/matlab/` once the port is validated on real cases | ☐ follow-up |

## 8. Out of scope (deliberate)

- Re-training or shipping the 2019-era TensorFlow wire-detection model (`WireDetection.h5`
  was never committed; socket integration was already disabled in 2020).
- Multi-user persistence / databases — JSON-lines per case directory matches the current
  research workflow; revisit if hosting becomes multi-tenant.
