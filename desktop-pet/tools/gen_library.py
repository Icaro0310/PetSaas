"""PetDeskSaas breed library generator.

For each breed: 12 generations via Pollinations (8 canonical stills +
4 walking frames), then deterministic derivation of all 13 states
(same technique as bake_breathe.py - one canonical sprite, warps only).

Output: pets/library/<breed-id>/{pet.json, spritesheet.webp, tray.png}
each one is directly installable as a .petpack.

Cache: pets/library-src/<breed>/{pose}_raw.png / *_cell.png - safe rerun.

Run with the frame-ronin-mcp venv python:
  C:/Users/Utilizador/AppData/Local/pipx/pipx/venvs/frame-ronin-mcp/Scripts/python.exe tools/gen_library.py
"""

import json
import sys
import time
from pathlib import Path

from PIL import Image

from sprite_gen.effects.breathe import (
    bake_breathe_sequence,
    recommended_breathe_frames,
)

# reuse helpers do gerador builtin
sys.path.insert(0, str(Path(__file__).resolve().parent))
from gen_pet_pollinations import fetch, process, unify_palette  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "pets" / "library-src"
LIB = ROOT / "pets" / "library"
FW = FH = 48

# ---- biblioteca de racas ------------------------------------------------

BREEDS = {
    # caes
    "labrador":        ("dog", "yellow labrador retriever dog"),
    "golden":          ("dog", "golden retriever dog, fluffy golden fur"),
    "german-shepherd": ("dog", "german shepherd dog, black and tan"),
    "bulldog":         ("dog", "english bulldog, stocky, wrinkled face"),
    "poodle":          ("dog", "white poodle dog, curly fur"),
    "beagle":          ("dog", "beagle dog, tricolor"),
    "yorkshire":       ("dog", "yorkshire terrier, tiny, silky fur"),
    "dachshund":       ("dog", "dachshund sausage dog, brown, long body"),
    "husky":           ("dog", "siberian husky, grey and white, blue eyes"),
    "pug":             ("dog", "pug dog, fawn, flat face"),
    "corgi":           ("dog", "pembroke corgi, orange and white"),
    "shiba":           ("dog", "shiba inu dog, orange, curled tail"),
    "border-collie":   ("dog", "border collie, black and white"),
    # SRD / vira-latas (brasileiros!)
    "srd-caramelo":    ("dog", "brazilian caramel mutt dog, short caramel fur, pointy ears"),
    "srd-preto":       ("dog", "black mutt dog, short fur, pointy ears"),
    "srd-branco":      ("dog", "white mutt dog, short fur, floppy ears"),
    # mais arquetipos populares
    "pinscher":        ("dog", "miniature pinscher, tiny, black and tan"),
    "pomeranian":      ("dog", "pomeranian spitz, fluffy orange, tiny"),
    "shih-tzu":        ("dog", "shih tzu, long fur, small, white and brown"),
    "pitbull":         ("dog", "pitbull dog, muscular, grey"),
    "rottweiler":      ("dog", "rottweiler dog, black and tan, big"),
    "cocker":          ("dog", "cocker spaniel, long ears, golden"),
    "maltes":          ("dog", "maltese dog, tiny, long white fur"),
    # gatos
    "orange-tabby":    ("cat", "orange tabby cat, striped"),
    "black-cat":       ("cat", "black cat, yellow eyes"),
    "siamese":         ("cat", "siamese cat, cream body, dark points"),
    "persian":         ("cat", "persian cat, fluffy white long fur"),
    "grey-tabby":      ("cat", "grey tabby cat, striped"),
    "tuxedo-cat":      ("cat", "tuxedo cat, black and white"),
    "calico":          ("cat", "calico cat, orange black white patches"),
    "maine-coon":      ("cat", "maine coon cat, large, fluffy brown"),
    "bengal":          ("cat", "bengal cat, spotted leopard-like"),
    "sphynx":          ("cat", "sphynx cat, hairless, pink skin"),
    "ragdoll":         ("cat", "ragdoll cat, fluffy, cream and grey, blue eyes"),
    "srd-gato":        ("cat", "mixed-breed house cat, brown tabby"),
}

STYLE = (
    ", one character only, centered, full body visible, "
    "16-bit retro pixel art game sprite, hard pixel edges, "
    "no anti-aliasing, flat colors, thick dark outline, "
    "pure white background"
)

# stills canonicas por estado (o resto deriva destas)
STILL_POSES = {
    "canonical": "sitting facing forward, big friendly eyes",
    "blink":     "sitting facing forward, eyes closed blinking",
    "sleeping":  "sleeping curled up, eyes closed",
    "petted":    "sitting, eyes closed in bliss, content smile",
    "eating":    "eating from a food bowl, head down",
    "thinking":  "sitting, paw on chin, thoughtful expression",
    "sad":       "sad, ears drooping, big watery eyes, sitting",
    "grooming":  "grooming, licking one front paw",
}

WALK_POSES = [
    "walking to the right, side view, left paw forward",
    "walking to the right, side view, right paw forward",
    "walking to the right, side view, legs together mid-step",
    "walking to the right, side view, mid-stride opposite",
]

# (fps, spec) — specs iguais ao bake_breathe.py mas autonomos por raca
STATE_SPECS = {
    "idle":     (5, {"still": "canonical",
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 2, "lag": 0.1},
                     "blink": "blink"}),
    "walking":  (7, "walk"),
    "running":  (12, {"reuse": "walking"}),
    "sleeping": (4, {"still": "sleeping",
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 2, "lag": 0.15}}),
    "waving":   (8, {"still": "canonical",
                     "breathe": {"depth": 0.09, "depth_x": 0,
                                 "breaths": 2, "lag": 0.0},
                     "wiggle": [0, 1, 2, 1, 0, -1, -2, -1,
                                0, 1, 2, 1, 0, -1, -2, -1,
                                0, 0]}),
    "petted":   (6, {"still": "petted",
                     "breathe": {"depth": 0.07, "depth_x": 0,
                                 "breaths": 2, "lag": 0.1}}),
    "eating":   (5, {"still": "eating",
                     "breathe": {"depth": 0.08, "depth_x": 0,
                                 "breaths": 1, "lag": 0.2}}),
    "playing":  (7, {"still": "canonical",
                     "breathe": {"depth": 0.07, "depth_x": 0,
                                 "breaths": 1, "lag": 0.0},
                     "wiggle": [0, 2, 0, -2, 0, 2, 0, -2],
                     "hop": [0, -2, -4, -2, 0, -2, -4, -2]}),
    "thinking": (4, {"still": "thinking",
                     "breathe": {"depth": 0.04, "depth_x": 0,
                                 "breaths": 1, "lag": 0.1}}),
    "jumping":  (9, {"still": "canonical",
                     "breathe": {"depth": 0.12, "depth_x": 0,
                                 "breaths": 1, "lag": 0.0},
                     "hop": [0, 0, -3, -6, -8, -6, -3, 0]}),
    "alert":    (10, {"still": "canonical",
                      "breathe": {"depth": 0.03, "depth_x": 0,
                                  "breaths": 3, "lag": 0.0}}),
    "sad":      (4, {"still": "sad",
                     "breathe": {"depth": 0.04, "depth_x": 0,
                                 "breaths": 1, "lag": 0.2}}),
    "grooming": (5, {"still": "grooming",
                     "breathe": {"depth": 0.05, "depth_x": 0,
                                 "breaths": 1, "lag": 0.1}}),
}

SPEECH = {
    "dog": {
        "pt": {"waving": ["Ola!", "Au au!", "Oi, humano!"],
               "sleeping": ["Zzz...", "Zzz... au..."],
               "petted": ["Que bom!", "Isso, continua."]},
        "en": {"waving": ["Hello!", "Woof!", "Hi, human!"],
               "sleeping": ["Zzz...", "Zzz... woof..."],
               "petted": ["So good!", "Yes, keep going."]},
    },
    "cat": {
        "pt": {"waving": ["Ola!", "Miau!", "Oi, humano!"],
               "sleeping": ["Zzz...", "Mrrr..."],
               "petted": ["Ronron...", "Miau~"]},
        "en": {"waving": ["Hello!", "Meow!", "Hi, human!"],
               "sleeping": ["Zzz...", "Purr..."],
               "petted": ["Purr...", "Meow~"]},
    },
}

REACTION_MAP = {
    "idle": "idle", "thinking": "thinking", "editing": "walking",
    "waiting": "idle", "success": "jumping", "error": "sad",
    "waving": "waving", "jumping": "jumping", "sleeping": "sleeping",
    "walking": "walking", "running": "running", "petted": "petted",
    "held": "alert", "falling": "alert", "eating": "eating",
    "playing": "playing", "alert": "alert", "sad": "sad",
    "grooming": "grooming",
}


def prompt(desc: str, pose: str) -> str:
    return f"single cute tiny {desc} mascot, {pose}{STYLE}"


def shift(img: Image.Image, dx: int, dy: int) -> Image.Image:
    if dx == 0 and dy == 0:
        return img
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (dx, dy), img)
    return out


def build_breed(breed_id: str, species: str, desc: str) -> bool:
    poses_dir = SRC / breed_id
    poses_dir.mkdir(parents=True, exist_ok=True)

    # 1. gera + processa stills e walk frames (cache-aware)
    cells: dict[str, Image.Image] = {}
    jobs = list(STILL_POSES.items()) + [
        (f"walk_{i}", p) for i, p in enumerate(WALK_POSES)
    ]
    for name, pose in jobs:
        cell_path = poses_dir / f"{name}_cell.png"
        if cell_path.exists():
            cells[name] = Image.open(cell_path).convert("RGBA")
            continue
        raw = poses_dir / f"{name}_raw.png"
        if not raw.exists():
            fetch(prompt(desc, pose), raw)
        cells[name] = process(raw, name, poses_dir)
        time.sleep(1)  # gentil com o pollinations

    # 2. deriva os 13 estados
    def build(spec):
        if spec == "walk":
            return [cells[f"walk_{i}"] for i in range(4)]
        if "reuse" in spec:
            return [f.copy() for f in build(STATE_SPECS[spec["reuse"]][1])]

        still = cells[spec["still"]]
        n = recommended_breathe_frames(spec["breathe"])
        for key in ("hop", "wiggle"):
            if key in spec:
                n = max(n, len(spec[key]))
        frames = [still.copy() for _ in range(n)]

        if spec.get("blink"):
            blink = cells[spec["blink"]]
            for i in (n - 4, n - 3):
                frames[i] = blink.copy()

        baked, _ = bake_breathe_sequence(frames, spec["breathe"])

        hop = spec.get("hop")
        wig = spec.get("wiggle")
        if hop or wig:
            baked = [
                shift(f,
                      wig[i % len(wig)] if wig else 0,
                      hop[i % len(hop)] if hop else 0)
                for i, f in enumerate(baked)
            ]
        return baked

    rows: list[list[Image.Image]] = []
    states_meta = {}
    for r, (name, (fps, spec)) in enumerate(STATE_SPECS.items()):
        frames = build(spec)
        states_meta[name] = {"row": r, "frames": len(frames), "fps": fps}
        rows.append(frames)

    # 3. sheet + paleta unificada + outputs
    cols = max(len(r) for r in rows)
    sheet = Image.new("RGBA", (FW * cols, FH * len(rows)), (0, 0, 0, 0))
    for r, frames in enumerate(rows):
        for c, f in enumerate(frames):
            sheet.paste(f, (c * FW, r * FH))
    sheet = unify_palette(sheet)

    out = LIB / breed_id
    out.mkdir(parents=True, exist_ok=True)
    sheet.save(poses_dir / "sheet.png")
    sheet.save(out / "spritesheet.webp", "WEBP", lossless=True)
    sheet.crop((0, 0, FW, FH)).resize(
        (32, 32), Image.Resampling.NEAREST
    ).save(out / "tray.png")

    manifest = {
        "id": breed_id,
        "displayName": breed_id.replace("-", " ").title(),
        "species": species,
        "description": f"PetDeskSaas library pet - {desc}, pixel art.",
        "spritesheetPath": "spritesheet.webp",
        "frameSize": [FW, FH],
        "states": states_meta,
        "reactionMap": REACTION_MAP,
        "speech": SPEECH[species],
    }
    (out / "pet.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    total = sum(len(r) for r in rows)
    print(f"[lib] {breed_id}: {len(rows)} states, {total} frames", flush=True)
    return True


def main() -> None:
    only = set(sys.argv[1:])
    for breed_id, (species, desc) in BREEDS.items():
        if only and breed_id not in only:
            continue
        if (LIB / breed_id / "pet.json").exists():
            print(f"[lib] {breed_id}: ja existe, skip", flush=True)
            continue
        try:
            build_breed(breed_id, species, desc)
        except Exception as e:
            print(f"[lib] {breed_id} FALHOU: {e}", flush=True)


if __name__ == "__main__":
    main()
