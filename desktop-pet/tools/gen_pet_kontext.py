"""Test img2img via Pollinations kontext model for consistent character.

Strategy: one canonical BASE image (generated once with turbo), then all
pose frames derived from it via kontext (image-to-image edit) so the
character stays identical across frames.
"""

import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "pets" / "builtin-src" / "kontext"
OUT.mkdir(parents=True, exist_ok=True)

UA = {"User-Agent": "PetDeskSaas/0.1"}
SEED = 42

BASE_PROMPT = (
    "single cute tiny white chihuahua dog mascot, wearing a pearl collar "
    "necklace around its neck, sitting facing forward, big friendly eyes, "
    "one character only, centered, full body visible, "
    "16-bit retro pixel art game sprite, hard pixel edges, "
    "no anti-aliasing, flat colors, thick dark outline, "
    "pure white background"
)

BASE_URL = (
    "https://image.pollinations.ai/prompt/"
    + urllib.parse.quote(BASE_PROMPT)
    + f"?width=512&height=512&model=turbo&nologo=true&seed={SEED}"
)


def get(url: str, dest: Path, tries: int = 8) -> bool:
    for t in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=240) as r:
                dest.write_bytes(r.read())
            return True
        except Exception as e:
            print(f"[k] try {t+1}: {e}", flush=True)
            time.sleep(min(10 * (t + 1), 60))
    return False


def main() -> None:
    base = OUT / "base.png"
    if not base.exists():
        print("[k] base...", flush=True)
        if not get(BASE_URL, base):
            print("[k] FALHOU base")
            return

    base_url = urllib.parse.quote(BASE_URL, safe="")
    test_pose = (
        "the same dog walking to the right, side view, left paw forward, "
        "same art style, same colors, pure white background"
    )
    url = (
        "https://image.pollinations.ai/prompt/"
        + urllib.parse.quote(test_pose)
        + f"?width=512&height=512&model=kontext&nologo=true&image={base_url}"
    )
    print("[k] kontext walk...", flush=True)
    if get(url, OUT / "walk_kontext.png"):
        print("[k] OK -> walk_kontext.png")
    else:
        print("[k] FALHOU kontext")


if __name__ == "__main__":
    main()
