"""Generate a PetDeskSaas pet via the FrameRonin RPG Maker pipeline.

Run with the frame-ronin-mcp pipx venv python:
  "C:\\Users\\Utilizador\\AppData\\Local\\pipx\\pipx\\venvs\\frame-ronin-mcp\\Scripts\\python.exe" tools/gen_pet.py

Pipeline: generate (Gemini free web, headless) -> dewatermark ->
white-to-alpha -> resize NEAREST -> split frames -> spritesheet.webp.
"""

import json
import sys
from pathlib import Path

from frame_ronin_mcp.tools.generate import handle_generate_rpgmaker
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent

PROMPT = (
    "cute chubby orange tabby cat mascot, sitting, big friendly eyes, "
    "simple clean silhouette, pixel art"
)


def main() -> None:
    out_dir = ROOT / "pets" / "builtin-src"
    out_dir.mkdir(parents=True, exist_ok=True)

    result = handle_generate_rpgmaker(
        {
            "prompt": PROMPT,
            "output_dir": str(out_dir),
            "backend": "gemini",
            "width": 48,
            "height": 48,
            "rows": 4,
            "columns": 4,
            "headless": True,
        }
    )
    print(json.dumps(result, indent=2))

    # Final asset: spritesheet.webp (192x192, alpha) in pets/builtin/
    builtin = ROOT / "pets" / "builtin"
    builtin.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(out_dir / "04_resized.png")
    sheet.save(builtin / "spritesheet.webp", "WEBP", lossless=True)
    print(f"[gen_pet] spritesheet.webp -> {builtin}")


if __name__ == "__main__":
    main()
