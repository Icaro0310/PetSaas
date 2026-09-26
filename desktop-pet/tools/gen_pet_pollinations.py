"""Generate the PetDeskSaas builtin pet via Pollinations.ai (free, no key).

~62 frames across 13 states. One image PER FRAME, then deterministic
post-processing:
  crop watermark -> rembg matte -> content-crop -> bottom-anchored
  square canvas -> 48x48 BOX resize -> hard alpha -> quantize 16 colors
  -> state rows x frame cols sheet.

Bottom anchoring keeps the feet baseline constant so frames read as
motion, not as a slideshow of different-sized sprites.

Also writes pets/builtin/pet.json (rows/fps) and pets/builtin/tray.png.

Run with the frame-ronin-mcp venv python. Raw generations are cached in
pets/builtin-src/poses/*_raw.png - safe to rerun after failures.
"""

import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image

from frame_ronin_mcp.tools.matting import handle_image_remove_background

ROOT = Path(__file__).resolve().parent.parent
FW, FH = 48, 48
GROUND_H = 40  # content height inside the 48px cell (feet on ground line)
SEED = 42
WM_CROP = 55  # px cortados do fundo (watermark pollinations)
ALPHA_MIN = 96  # threshold p/ alpha duro (pixel art sem fringes)

BASE = (
    "single cute tiny white chihuahua dog mascot, "
    "wearing a pearl collar necklace around its neck, {pose}, "
    "one character only, centered, full body visible, "
    "16-bit retro pixel art game sprite, hard pixel edges, "
    "no anti-aliasing, flat colors, thick dark outline, "
    "pure white background"
)

# state -> (fps, [frame poses em ordem de animacao])
STATES = {
    "idle": (3, [
        "sitting facing forward, big friendly eyes",
        "sitting facing forward, eyes closed blinking",
        "sitting, head tilted left, curious",
        "sitting, head tilted right, curious",
        "sitting, looking to the left, tail curled",
        "sitting, looking to the right, ears perked",
    ]),
    "walking": (8, [
        "walking to the right, side view, left paw forward",
        "walking to the right, side view, left paw planted",
        "walking to the right, side view, legs together mid-step",
        "walking to the right, side view, right paw forward",
        "walking to the right, side view, right paw planted",
        "walking to the right, side view, legs together passing",
    ]),
    "running": (10, [
        "running to the right, body stretched, front paws extended",
        "running to the right, all paws tucked under body",
        "running to the right, hind paws extended back",
        "running to the right, all paws gathered mid-air",
    ]),
    "sleeping": (2, [
        "sleeping curled up, eyes closed",
        "sleeping curled up, eyes closed, tail wrapped",
        "sleeping on side, legs stretched, eyes closed",
        "sleeping curled up, head resting on paws",
    ]),
    "waving": (5, [
        "standing on hind legs, waving left paw, mouth open smiling",
        "standing on hind legs, both paws up, happy",
        "standing on hind legs, waving right paw, mouth open smiling",
        "standing on hind legs, both paws up, happy",
    ]),
    "petted": (4, [
        "sitting, eyes closed in bliss, head leaning to the side",
        "sitting, eyes closed, purring, smile",
        "sitting, eyes closed, leaning into a pet, tongue out slightly",
        "sitting, eyes closed, content smile, head tilted",
    ]),
    "eating": (4, [
        "eating from a food bowl, head down",
        "eating from a food bowl, head slightly up, chewing",
        "eating from a food bowl, head tilted, munching",
        "eating from a food bowl, head up, licking lips",
    ]),
    "playing": (6, [
        "playing, paws batting a small red ball",
        "pouncing playfully, front paws forward, tail wagging",
        "playing, chasing tail, spinning",
        "playing, crouched ready to pounce, tail up",
        "playing, mid-pounce in the air",
        "playing, standing with red ball under paw, proud",
    ]),
    "thinking": (3, [
        "sitting, paw on chin, thoughtful expression",
        "sitting, looking up, one eyebrow raised, puzzled",
        "sitting, head tilted, paw scratching head",
    ]),
    "jumping": (5, [
        "crouching low, ready to jump",
        "jumping up high, all paws off ground, excited",
        "mid-air jump at peak, paws spread, big smile",
        "landing, knees bent, paws touching ground",
    ]),
    "alert": (5, [
        "surprised, wide eyes, ears perked up, sitting",
        "startled, fur puffed, arched back, wide eyes",
        "alert, standing stiff, ears pointed forward, staring",
        "surprised, mouth open gasp, ears up",
    ]),
    "sad": (3, [
        "sad, ears drooping, big watery eyes, sitting",
        "sad, lying flat on belly, ears down, whimpering",
        "sad, head down low, puppy eyes looking up",
    ]),
    "grooming": (4, [
        "grooming, licking one front paw",
        "grooming, head bent licking chest",
        "grooming, licking paw then wiping face",
        "grooming, scratching ear with hind paw",
    ]),
}


def fetch(prompt: str, dest: Path, tries: int = 8) -> None:
    url = (
        "https://image.pollinations.ai/prompt/"
        + urllib.parse.quote(prompt)
        + f"?width=512&height=512&model=turbo&nologo=true&seed={SEED}"
        + "&enhance=false"
    )
    for t in range(tries):
        try:
            req = urllib.request.Request(
                url, headers={"User-Agent": "PetDeskSaas/0.1"}
            )
            with urllib.request.urlopen(req, timeout=240) as r:
                dest.write_bytes(r.read())
            return
        except Exception as e:
            print(f"[gen] try {t+1} falhou: {e}", flush=True)
            time.sleep(min(10 * (t + 1), 60))
    raise RuntimeError(f"pollinations falhou: {prompt[:40]}")


def frame_cell(img: Image.Image) -> Image.Image:
    """RGBA com matte -> cell 48x48, conteudo ancornado no chao.

    O character ocupa ate GROUND_H px de altura, com os pes na base do
    cell - registo consistente entre frames = movimento fluido.
    Sem quantize aqui: a paleta e' unificada na sheet completa.
    """
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)

    # escala p/ altura alvo, respeitando a largura maxima do cell
    s = min(GROUND_H / img.height, FW / img.width)
    w = max(1, round(img.width * s))
    h = max(1, round(img.height * s))
    img = img.resize((w, h), Image.Resampling.LANCZOS)

    cell = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    cell.paste(img, ((FW - w) // 2, FH - h))  # bottom-center

    # alpha duro (sem fringes); cor fica para a paleta global
    alpha = cell.getchannel("A").point(lambda v: 255 if v >= ALPHA_MIN else 0)
    cell.putalpha(alpha)
    return cell


def unify_palette(sheet: Image.Image, colors: int = 16) -> Image.Image:
    """Uma paleta unica para TODOS os frames -> cores consistentes."""
    alpha = sheet.getchannel("A")
    q = sheet.convert("RGB").quantize(
        colors=colors, method=Image.Quantize.MEDIANCUT
    ).convert("RGBA")
    q.putalpha(alpha)
    return q


def process(raw: Path, stem: str, out: Path) -> Image.Image:
    nobg = out / f"{stem}_nobg.png"
    if not nobg.exists():
        img = Image.open(raw).convert("RGBA")
        img = img.crop((0, 0, img.width, img.height - WM_CROP))
        cropped = out / f"{stem}_crop.png"
        img.save(cropped)
        handle_image_remove_background(
            {"image_path": str(cropped), "output_path": str(nobg)}
        )

    cell = frame_cell(Image.open(nobg).convert("RGBA"))
    cell.save(out / f"{stem}_cell.png")
    return cell


def write_manifest(n_rows: int) -> None:
    states = {}
    row = 0
    for name, (fps, poses) in STATES.items():
        states[name] = {"row": row, "frames": len(poses), "fps": fps}
        row += 1
    manifest = {
        "id": "chihuahua-pixel",
        "displayName": "Chihuahua",
        "description": "PetDeskSaas builtin pet - tiny white chihuahua "
                       "with a pearl collar, pixel art.",
        "spritesheetPath": "spritesheet.webp",
        "frameSize": [FW, FH],
        "states": states,
        "reactionMap": {
            "idle": "idle", "thinking": "thinking", "editing": "walking",
            "waiting": "idle", "success": "jumping", "error": "sad",
            "waving": "waving", "jumping": "jumping", "sleeping": "sleeping",
            "walking": "walking", "running": "running", "petted": "petted",
            "held": "alert", "falling": "alert", "eating": "eating",
            "playing": "playing", "alert": "alert", "sad": "sad",
            "grooming": "grooming",
        },
        "speech": {
            "pt": {
                "waving": ["Ola!", "Au au!", "Oi, humano!"],
                "success": ["Conseguiste!", "Boa!", "Au au de parabens!"],
                "error": ["Ups...", "Algo correu mal.", "Vou fingir que nao vi."],
                "sleeping": ["Zzz...", "Zzz... au..."],
                "petted": ["Que bom!", "Isso, continua."],
                "thinking": ["Hmm...", "A pensar..."],
            },
            "en": {
                "waving": ["Hello!", "Woof!", "Hi, human!"],
                "success": ["You did it!", "Nice!", "Woof, congrats!"],
                "error": ["Oops...", "Something went wrong.",
                          "I'll pretend I didn't see that."],
                "sleeping": ["Zzz...", "Zzz... woof..."],
                "petted": ["So good!", "Yes, keep going."],
                "thinking": ["Hmm...", "Thinking..."],
            },
        },
    }
    (ROOT / "pets" / "builtin" / "pet.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8"
    )


def main() -> None:
    out = ROOT / "pets" / "builtin-src" / "poses"
    out.mkdir(parents=True, exist_ok=True)

    rows: list[list[Image.Image]] = []
    for state, (fps, poses) in STATES.items():
        cells = []
        for i, pose in enumerate(poses):
            stem = f"{state}_{i}"
            raw = out / f"{stem}_raw.png"
            if not raw.exists():
                fetch(BASE.format(pose=pose), raw)
            cells.append(process(raw, stem, out))
        print(f"[gen] {state}: {len(cells)} frames", flush=True)
        rows.append(cells)

    cols = max(len(r) for r in rows)
    sheet = Image.new("RGBA", (FW * cols, FH * len(rows)), (0, 0, 0, 0))
    for r, cells in enumerate(rows):
        for c, cell in enumerate(cells):
            sheet.paste(cell, (c * FW, r * FH))

    sheet = unify_palette(sheet)

    builtin = ROOT / "pets" / "builtin"
    builtin.mkdir(parents=True, exist_ok=True)
    sheet.save(out / "sheet.png")
    sheet.save(builtin / "spritesheet.webp", "WEBP", lossless=True)

    # tray icon a partir do primeiro frame do idle
    idle0 = sheet.crop((0, 0, FW, FH))
    idle0.resize((32, 32), Image.Resampling.NEAREST).save(
        builtin / "tray.png"
    )
    write_manifest(len(rows))

    total = sum(len(r) for r in rows)
    print(
        f"[gen] DONE -> {builtin / 'spritesheet.webp'} "
        f"({sheet.width}x{sheet.height}, {len(rows)} states, "
        f"{total} frames)",
        flush=True,
    )


if __name__ == "__main__":
    main()
