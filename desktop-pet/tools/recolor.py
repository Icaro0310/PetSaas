"""Palette-swap for PetDeskSaas spritesheets - deterministic, pixel-true.

A sheet is 16-color quantized, so recoloring = remapping palette indices.
No regeneration, no AI - instant and free.

Usage:
  python tools/recolor.py <sheet.webp> --to "#8B4513" --out out.webp
  python tools/recolor.py <sheet.webp> --coat caramelo --out out.webp
  python tools/recolor.py <sheet.webp> --from-photo rex.jpg --out out.webp

Fur detection: opaque pixels clustered; near-black (outline) and
near-white (highlight) excluded; the largest remaining chromatic
cluster = fur tones. Each fur color is hue-rotated toward the target
keeping its own value/saturation ratio (shading survives).
"""

import argparse
import colorsys
from pathlib import Path

from PIL import Image

# presets de pelagem (alvo aproximado; o shading vem do sprite)
COATS = {
    "caramelo":  (0xC8, 0x86, 0x3C),
    "chocolate": (0x5B, 0x3A, 0x24),
    "preto":     (0x3A, 0x34, 0x30),
    "branco":    (0xEE, 0xEA, 0xE2),
    "cinza":     (0x8A, 0x8A, 0x8E),
    "creme":     (0xE8, 0xD8, 0xB0),
    "dourado":   (0xD9, 0xA4, 0x4A),
    "vermelho":  (0xA8, 0x50, 0x30),
}


def fur_indices(img: Image.Image) -> set[int]:
    """Indices da paleta que sao 'pelo': exclui contorno escuro,
    highlights quase brancos, e cores muito saturadas (coleira/boca)."""
    pal = img.convert("P")
    palette = pal.getpalette()
    hist = pal.histogram()
    counts = {i: c for i, c in enumerate(hist[:256]) if c > 0}
    if not counts:
        return set()

    keep: dict[int, int] = {}
    for i, count in counts.items():
        r, g, b = palette[i * 3 : i * 3 + 3]
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        if v < 0.22:   # contorno / olhos / nariz
            continue
        if v > 0.93 and s < 0.12:  # branco puro (highlight)
            continue
        if s > 0.72:   # coleira, lingua, props
            continue
        keep[i] = count

    if not keep:
        return set()
    # cluster dominante = indices com >=15% do maior count
    top = max(keep.values())
    return {i for i, c in keep.items() if c >= top * 0.15}


def dominant_color(photo: Image.Image) -> tuple[int, int, int]:
    """Cor dominante da foto real: media dos pixels do centro,
    ignorando extremos (fundo claro/escuro)."""
    img = photo.convert("RGB")
    w, h = img.size
    img = img.crop((w // 4, h // 4, 3 * w // 4, 3 * h // 4))
    img = img.resize((32, 32), Image.Resampling.BOX)
    px = list(img.getdata())
    vals = [p for p in px if 0.15 < sum(p) / 765 < 0.9]
    if not vals:
        vals = px
    n = len(vals)
    return tuple(sum(p[i] for p in vals) // n for i in range(3))


def recolor(sheet: Image.Image, target: tuple[int, int, int],
            strength: float = 0.85) -> Image.Image:
    """Hue-shift dos tons de pelo para a cor alvo, preservando o V
    relativo de cada tom (o shading pixel-art sobrevive)."""
    rgba = sheet.convert("RGBA")
    th, ts, tv = colorsys.rgb_to_hsv(*(c / 255 for c in target))

    fur = fur_indices(rgba)
    pal = rgba.convert("P")
    palette = pal.getpalette()
    if not fur:
        return rgba

    # media V dos tons de pelo para normalizar a escala
    vs = []
    for i in fur:
        r, g, b = palette[i * 3 : i * 3 + 3]
        vs.append(colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)[2])
    v_ref = sum(vs) / len(vs) or 0.5

    new_palette = list(palette)
    for i in fur:
        r, g, b = palette[i * 3 : i * 3 + 3]
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        # preserva a posicao relativa do tom dentro do cluster
        v2 = min(1.0, max(0.05, tv * (v / v_ref)))
        s2 = ts * strength + s * (1 - strength)
        nr, ng, nb = colorsys.hsv_to_rgb(th, s2, v2)
        new_palette[i * 3 : i * 3 + 3] = (
            round(nr * 255), round(ng * 255), round(nb * 255)
        )

    pal.putpalette(new_palette)
    out = pal.convert("RGBA")
    out.putalpha(rgba.getchannel("A"))
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("sheet")
    ap.add_argument("--to", help='cor alvo "#RRGGBB"')
    ap.add_argument("--coat", choices=sorted(COATS))
    ap.add_argument("--from-photo", dest="photo")
    ap.add_argument("--strength", type=float, default=0.85)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    if a.to:
        t = a.to.lstrip("#")
        target = tuple(int(t[i : i + 2], 16) for i in (0, 2, 4))
    elif a.coat:
        target = COATS[a.coat]
    elif a.photo:
        target = dominant_color(Image.open(a.photo))
        print(f"[recolor] cor extraida da foto: #{target[0]:02x}"
              f"{target[1]:02x}{target[2]:02x}")
    else:
        ap.error("precisa de --to, --coat ou --from-photo")

    out = recolor(Image.open(a.sheet), target, a.strength)
    Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    out.save(a.out, "WEBP", lossless=True)
    print(f"[recolor] {a.out}")


if __name__ == "__main__":
    main()
