"""Base class for surgical procedures."""

from dataclasses import dataclass
from typing import ClassVar

PROCEDURE_NAMES = ("DHS Tip-Apex Distance", "Pediatric Supracondylar Humerus Fracture")


@dataclass
class Procedure:
    """Abstract base class for surgical procedures."""

    name: ClassVar[str]

    def ready(self) -> bool:
        """Check if procedure is ready to evaluate."""
        raise NotImplementedError

    def evaluate(self) -> dict:
        """Evaluate the procedure and return metrics."""
        raise NotImplementedError
