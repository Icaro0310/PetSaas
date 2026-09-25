"""Empacota a biblioteca de racas em .petpack + variantes recolor.

Para cada breed em pets/library/<breed>/:
  - petpack base: <breed>.petpack   (pet.json + spritesheet.webp + tray.png)
  - por cada coat preset: <breed>__<coat>.petpack com sheet/tray
    recoloridos deterministicamente via recolor.py (palette-swap).

Output: pets/petpacks/*.petpack  — depois `upload_petpacks.py` sobe-os
para o bucket Supabase `petpacks/library/`.

    python tools/pack_petpacks.py
"""

import json
import sys
import tempfile
import zipfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from recolor import COATS, recolor  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "pets" / "library"
OUT = ROOT / "pets" / "petpacks"

ENTRIES = ("pet.json", "spritesheet.webp", "tray.png")


def write_pack(dest: Path, pet_json: dict, sheet: Path, tray: Path) -> None:
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("pet.json", json.dumps(pet_json, indent=2))
        z.write(sheet, "spritesheet.webp")
        z.write(tray, "tray.png")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    breeds = sorted(d for d in LIB.iterdir() if (d / "pet.json").exists())
    if not breeds:
        sys.exit("sem breeds em pets/library/")

    total = 0
    for breed_dir in breeds:
        manifest = json.loads((breed_dir / "pet.json").read_text("utf8"))
        breed = manifest["id"]
        sheet = breed_dir / "spritesheet.webp"
        tray = breed_dir / "tray.png"

        # base
        write_pack(OUT / f"{breed}.petpack", manifest, sheet, tray)
        print(f"[pack] {breed}.petpack")
        total += 1

        # variantes recolor
        for coat, target in COATS.items():
            vid = f"{breed}__{coat}"
            with tempfile.TemporaryDirectory() as td:
                td = Path(td)
                rsheet = td / "spritesheet.webp"
                rtray = td / "tray.png"
                recolor(Image.open(sheet), target).save(
                    rsheet, "WEBP", lossless=True
                )
                recolor(Image.open(tray), target).save(rtray, "PNG")
                m = dict(manifest)
                m["id"] = vid
                m["displayName"] = f"{manifest['displayName']} {coat.title()}"
                write_pack(OUT / f"{vid}.petpack", m, rsheet, rtray)
            print(f"[pack] {vid}.petpack")
            total += 1

    print(f"[done] {total} petpacks em {OUT}")


if __name__ == "__main__":
    main()
