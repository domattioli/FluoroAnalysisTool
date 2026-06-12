"""Image enhancement utilities."""

import numpy as np
from PIL import Image


def to_uint8(
    img: np.ndarray, window_center: float | None = None, window_width: float | None = None
) -> np.ndarray:
    """
    Float window/level mapping to [0, 255] uint8 with clipping.

    Default center = (min + max) / 2, width = max - min.
    Width < 1 is clamped to 1.
    """
    img = np.asarray(img)
    if img.size == 0:
        return np.array([], dtype=np.uint8).reshape(img.shape)

    min_val = float(np.min(img))
    max_val = float(np.max(img))

    if window_center is None:
        window_center = (min_val + max_val) / 2
    if window_width is None:
        window_width = max_val - min_val
    if window_width < 1:
        window_width = 1

    lower = window_center - window_width / 2
    upper = window_center + window_width / 2

    # Clamp and scale to [0, 255]
    clipped = np.clip(img, lower, upper)
    scaled = (clipped - lower) / (upper - lower) * 255
    return scaled.astype(np.uint8)


def histogram_equalize(img8: np.ndarray) -> np.ndarray:
    """
    Histogram equalization on uint8.

    Classic CDF equalization using bincount/cumsum (no scipy/skimage).
    """
    img8 = np.asarray(img8, dtype=np.uint8)
    original_shape = img8.shape
    flat = img8.flatten()

    # Compute histogram
    hist = np.bincount(flat, minlength=256)

    # Compute CDF
    cdf = np.cumsum(hist)
    cdf_normalized = (cdf - cdf.min()) / (cdf.max() - cdf.min()) * 255

    # Map each pixel
    result = cdf_normalized[flat].astype(np.uint8)
    return result.reshape(original_shape)


def invert(img8: np.ndarray) -> np.ndarray:
    """Invert grayscale uint8 image: 255 - img."""
    img8 = np.asarray(img8, dtype=np.uint8)
    return (255 - img8).astype(np.uint8)


def to_pil_rgb(img8: np.ndarray) -> Image.Image:
    """Convert grayscale uint8 to RGB PIL image."""
    img8 = np.asarray(img8, dtype=np.uint8)
    return Image.fromarray(img8, mode="L").convert("RGB")
