"""Strip-based generation: ONE image per animation state = a horizontal
row of N frames of the SAME drawing (model keeps character consistent
within a single generation). Then slice row into N equal cells.

Test: only the 'walking' state first to validate the approach.
"""

import time
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image

from frame_ronin_mcp.tools.matting import handle_image_remove_background

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "pets" / "builtin-src" / "strips"
OUT.mkdir(parents=True, exist_ok=True)

UA = {"User-Agent": "PetDeskSaas/0.1"}
SEED = 42
WM_CROP = 0.10  # corta 10% do fundo (watermark)

DESC = (
    "the same white chihuahua dog wearing a pearl collar necklace, "
    "16-bit retro pixel art game sprite, hard pixel edges, flat colors, "
    "thick dark outline, pure white background"
)


def get(url: str, dest: Path, tries: int = 8) -> bool:
    for t in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=240) as r:
                dest.write_bytes(r.read())
            return True
        except Exception as e:
            print(f"[s] try {t+1}: {e}", flush=True)
            time.sleep(min(10 * (t + 1), 60))
    return False


def strip_url(state_desc: str, n: int, w: int, h: int) -> str:
    prompt = (
        f"pixel art sprite sheet, one single horizontal row of exactly "
        f"{n} animation frames showing {state_desc}, {DESC}, "
        f"all {n} frames equal size and evenly spaced in a grid, "
        f"no text, no watermark"
    )
    return (
        "https://image.pollinations.ai/prompt/" + urllib.parse.quote(prompt)
        + f"?width={w}&height={h}&model=turbo&nologo=true&seed={SEED}"
    )


def slice_strip(img: Image.Image, n: int) -> list[Image.Image]:
    """Corta a faixa em n celulas iguais, aplica matte por celula."""
    w, h = img.size
    cw = w // n
    cells = []
    for i in range(n):
        cells.append(img.crop((i * cw, 0, (i + 1) * cw, h)))
    return cells


def main() -> None:
    # teste: walking, 6 frames numa faixa 2048x512 (~341px por frame)
    n = 6
    url = strip_url(
        "a dog walking cycle: left paw forward, left paw planted, "
        "legs together, right paw forward, right paw planted, legs pass",
        n, 2048, 512,
    )
    strip = OUT / "walking_strip.png"
    print("[s] walking strip...", flush=True)
    if not get(url, strip):
        print("[s] FALHOU")
        return
    img = Image.open(strip).convert("RGBA")
    img = img.crop((0, 0, img.width, int(img.height * (1 - WM_CROP))))
    cells = slice_strip(img, n)
    for i, c in enumerate(cells):
        c.save(OUT / f"walk_cell{i}_raw.png")
        nobg = OUT / f"walk_cell{i}_nobg.png"
        handle_image_remove_background(
            {"image_path": str(c), "output_path": str(nobg)}
        )
    print("[s] OK -> 6 cells")


if __name__ == "__main__":
    main()
