"""Pack every pets/library/<id>/ into pets/library-packs/<id>.petpack.

A .petpack is a plain ZIP with pet.json + spritesheet.webp + tray.png at
the root - the contract src/main/petpack.ts validates on install.
Also emits library-index.json for the website's breed dropdown.
"""

import json
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "pets" / "library"
PACKS = ROOT / "pets" / "library-packs"

REQUIRED = ("pet.json", "spritesheet.webp", "tray.png")


def main() -> None:
    PACKS.mkdir(parents=True, exist_ok=True)
    index = []
    for pet_dir in sorted(LIB.iterdir()):
        if not pet_dir.is_dir():
            continue
        missing = [f for f in REQUIRED if not (pet_dir / f).exists()]
        if missing:
            print(f"[pack] {pet_dir.name}: INCOMPLETO {missing}")
            continue
        manifest = json.loads(
            (pet_dir / "pet.json").read_text(encoding="utf-8")
        )
        out = PACKS / f"{pet_dir.name}.petpack"
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
            for f in REQUIRED:
                z.write(pet_dir / f, f)
        index.append(
            {
                "id": manifest["id"],
                "displayName": manifest.get("displayName", pet_dir.name),
                "species": manifest.get("species", "dog"),
                "pack": f"{pet_dir.name}.petpack",
            }
        )
        print(f"[pack] {out.name} ({out.stat().st_size // 1024} KB)")

    (PACKS / "library-index.json").write_text(
        json.dumps(index, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print(f"[pack] DONE -> {PACKS} ({len(index)} packs)")


if __name__ == "__main__":
    main()
