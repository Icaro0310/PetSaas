"""Bake final sheet: derive every state from curated stills + deterministic
warps (breathe / wiggle / hop). One canonical base keeps the dog identical
across all states - no mid-animation identity swaps.

Techniques (all pixel-true, deterministic):
- breathe: sprite-gen squash&stretch on replicated stills
- wiggle: integer x-shift alternation (excited wiggle without redraw)
- hop: integer y-shift parabola (jump reads via content offset)
- reuse: share a row between states at different fps
"""

import json
from pathlib import Path

from PIL import Image

from sprite_gen.effects.breathe import (
    bake_breathe_sequence,
    recommended_breathe_frames,
)

ROOT = Path(__file__).resolve().parent.parent
POSES = ROOT / "pets" / "builtin-src" / "poses"
OUT = ROOT / "pets" / "builtin"
FW = FH = 48

# estado -> (fps, spec)
#  int              -> N frames gerados curados [0..n)
#  [int,...]        -> frames gerados selecionados por indice
#  {"still": (s,i), "breathe": cfg, "blink": (s,i)?,
#   "hop": [dy,...], "wiggle": [dx,...], "repeat": n}
#  {"reuse": name}  -> partilha a row de outro estado
STATES = {
    "idle":     (5, {"still": ("idle", 0),
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 2, "lag": 0.1},
                     "blink": ("idle", 1)}),
    "walking":  (7, [0, 1, 3, 4]),   # stride frames mais consistentes
    "running":  (12, {"reuse": "walking"}),
    "sleeping": (4, {"still": ("sleeping", 0),
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 2, "lag": 0.15}}),
    "waving":   (8, {"still": ("idle", 0),
                     "breathe": {"depth": 0.09, "depth_x": 0,
                                 "breaths": 2, "lag": 0.0},
                     "wiggle": [0, 1, 2, 1, 0, -1, -2, -1,
                                0, 1, 2, 1, 0, -1, -2, -1,
                                0, 0]}),
    "petted":   (6, {"still": ("petted", 0),
                     "breathe": {"depth": 0.07, "depth_x": 0,
                                 "breaths": 2, "lag": 0.1}}),
    "eating":   (5, {"still": ("eating", 0),
                     "breathe": {"depth": 0.08, "depth_x": 0,
                                 "breaths": 1, "lag": 0.2}}),
    "playing":  (7, [1, 3, 4]),   # pounce frames sem a bola (prop consistente)
    "thinking": (4, {"still": ("thinking", 0),
                     "breathe": {"depth": 0.04, "depth_x": 0,
                                 "breaths": 1, "lag": 0.1}}),
    "jumping":  (9, {"still": ("idle", 0),
                     "breathe": {"depth": 0.12, "depth_x": 0,
                                 "breaths": 1, "lag": 0.0},
                     "hop": [0, 0, -3, -6, -8, -6, -3, 0]}),
    "alert":    (10, {"still": ("idle", 0),
                      "breathe": {"depth": 0.03, "depth_x": 0,
                                  "breaths": 3, "lag": 0.0}}),
    "sad":      (4, {"still": ("sad", 0),
                     "breathe": {"depth": 0.04, "depth_x": 0,
                                 "breaths": 1, "lag": 0.2}}),
    "grooming": (5, {"still": ("grooming", 0),
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 1, "lag": 0.1}}),
}


def cell(state: str, idx: int) -> Image.Image:
    return Image.open(POSES / f"{state}_{idx}_cell.png").convert("RGBA")


def shift(img: Image.Image, dx: int, dy: int) -> Image.Image:
    """Desloca o conteudo (dx,dy) px. Pixel-true, sem wrap."""
    if dx == 0 and dy == 0:
        return img
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (dx, dy), img)
    return out


def build_state(name: str, cfg) -> list[Image.Image]:
    if isinstance(cfg, int):
        return [cell(name, i) for i in range(cfg)]
    if isinstance(cfg, list):
        return [cell(name, i) for i in cfg]

    if "reuse" in cfg:
        frames = build_state(cfg["reuse"], STATES[cfg["reuse"]][1])
        return [f.copy() for f in frames]

    still = cell(*cfg["still"])
    n = recommended_breathe_frames(cfg["breathe"])
    for key in ("hop", "wiggle"):
        if key in cfg:
            n = max(n, len(cfg[key]))
    frames = [still.copy() for _ in range(n)]

    if cfg.get("blink") is not None:
        blink = cell(*cfg["blink"])
        for i in (n - 4, n - 3):
            frames[i] = blink.copy()

    baked, _ = bake_breathe_sequence(frames, cfg["breathe"])

    hop = cfg.get("hop")
    wig = cfg.get("wiggle")
    if hop or wig:
        out = []
        for i, f in enumerate(baked):
            dx = wig[i % len(wig)] if wig else 0
            dy = hop[i % len(hop)] if hop else 0
            out.append(shift(f, dx, dy))
        baked = out
    return baked


def unify_palette(sheet: Image.Image, colors: int = 16) -> Image.Image:
    alpha = sheet.getchannel("A")
    q = sheet.convert("RGB").quantize(
        colors=colors, method=Image.Quantize.MEDIANCUT
    ).convert("RGBA")
    q.putalpha(alpha)
    return q


def main() -> None:
    rows: list[list[Image.Image]] = []
    states_meta = {}
    for r, (name, (fps, cfg)) in enumerate(STATES.items()):
        frames = build_state(name, cfg)
        states_meta[name] = {"row": r, "frames": len(frames), "fps": fps}
        rows.append(frames)
        print(f"[bake] {name}: {len(frames)} frames @ {fps}fps", flush=True)

    cols = max(len(r) for r in rows)
    sheet = Image.new("RGBA", (FW * cols, FH * len(rows)), (0, 0, 0, 0))
    for r, frames in enumerate(rows):
        for c, f in enumerate(frames):
            sheet.paste(f, (c * FW, r * FH))

    sheet = unify_palette(sheet)
    OUT.mkdir(parents=True, exist_ok=True)
    sheet.save(POSES / "sheet_baked.png")
    sheet.save(OUT / "spritesheet.webp", "WEBP", lossless=True)

    sheet.crop((0, 0, FW, FH)).resize(
        (32, 32), Image.Resampling.NEAREST
    ).save(OUT / "tray.png")

    manifest = json.loads((OUT / "pet.json").read_text(encoding="utf-8"))
    manifest["states"] = states_meta
    (OUT / "pet.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    total = sum(len(r) for r in rows)
    print(
        f"[bake] DONE -> {OUT / 'spritesheet.webp'} "
        f"({sheet.width}x{sheet.height}, {len(rows)} states, "
        f"{total} frames)",
        flush=True,
    )


if __name__ == "__main__":
    main()
