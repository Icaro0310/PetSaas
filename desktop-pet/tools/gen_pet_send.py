"""Attach to running Chrome (port 9222), send the Gemini prompt via the
send button (Enter does not submit in Gemini's contenteditable composer),
wait for the generated image, and run the FrameRonin post-pipeline.
"""

import asyncio
import base64
import sys
import time
from pathlib import Path

from playwright.async_api import async_playwright
from PIL import Image

from frame_ronin_mcp.tools.generate import expand_prompt
from frame_ronin_mcp.lib.watermark import remove_gemini_watermark
from frame_ronin_mcp.lib.image_utils import load_image, save_image, white_to_alpha

ROOT = Path(__file__).resolve().parent.parent
ROWS, COLS, FW, FH = 4, 4, 48, 48
PROMPT = (
    "cute chubby orange tabby cat mascot, sitting, big friendly eyes, "
    "simple clean silhouette, pixel art"
)

SEND_SEL = (
    'button[aria-label*="Enviar" i], button[aria-label*="Send" i], '
    'button.send-button, button[mattooltip*="Enviar" i], '
    'button[mattooltip*="Send" i]'
)


async def dismiss_banners(page) -> None:
    for name in ("Dispensar", "Dismiss", "Got it", "Percebi", "OK"):
        try:
            b = page.get_by_role("button", name=name).first
            if await b.is_visible(timeout=400):
                await b.click()
                print(f"[gen] banner '{name}' dismissed", flush=True)
        except Exception:
            pass


async def grab_image(page, out_path: Path, timeout: int = 240) -> Path:
    start = time.time()
    while time.time() - start < timeout:
        await asyncio.sleep(2)
        try:
            dl = page.locator(
                '[data-test-id="download-generated-image-button"]'
            ).last
            if await dl.is_visible():
                async with page.expect_download(timeout=30000) as di:
                    await dl.click()
                await (await di.value).save_as(str(out_path))
                return out_path
        except Exception:
            pass
        try:
            b64 = await page.evaluate(
                """async () => {
                    const imgs=[...document.querySelectorAll('img')]
                        .filter(i=>i.src.startsWith('blob:'));
                    if(!imgs.length)return null;
                    const c=document.createElement('canvas');
                    c.width=imgs[0].naturalWidth;
                    c.height=imgs[0].naturalHeight;
                    c.getContext('2d').drawImage(imgs[0],0,0);
                    return c.toDataURL('image/png');
                }"""
            )
            if b64:
                out_path.write_bytes(base64.b64decode(b64.split(",", 1)[1]))
                return out_path
        except Exception:
            pass
    raise TimeoutError(f"timeout {timeout}s")


async def main() -> None:
    out = ROOT / "pets" / "builtin-src"
    out.mkdir(parents=True, exist_ok=True)
    raw = out / "01_raw.png"

    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://127.0.0.1:9222")
        ctx = browser.contexts[0]
        page = next(
            (pg for pg in ctx.pages if "gemini.google.com" in pg.url),
            ctx.pages[0],
        )
        await dismiss_banners(page)

        tb = page.get_by_role("textbox").first
        content = (await tb.inner_text()).strip()
        if not content:
            prompt = expand_prompt(PROMPT, style="rpgmaker")
            await tb.click()
            await tb.fill(
                f"{prompt}\nGenerate as a pixel art RPG Maker MV sprite "
                f"sheet: exactly {ROWS} rows x {COLS} columns of "
                f"{FW}x{FH} pixel frames. White background."
            )
            await asyncio.sleep(1)

        send = page.locator(SEND_SEL).last
        if await send.count() and await send.is_visible():
            await send.click()
            print("[gen] send clicado", flush=True)
        else:
            await tb.click()
            await page.keyboard.press("Enter")
            print("[gen] fallback Enter", flush=True)

        await grab_image(page, raw)
        print(f"[gen] imagem -> {raw}", flush=True)
        await browser.close()

    img = load_image(raw)
    save_image(remove_gemini_watermark(img), out / "02_clean.png")
    nobg = white_to_alpha(load_image(out / "02_clean.png"))
    save_image(nobg, out / "03_nobg.png")
    sheet = nobg.resize((COLS * FW, ROWS * FH), Image.Resampling.NEAREST)
    save_image(sheet, out / "04_resized.png")

    frames_dir = out / "frames"
    frames_dir.mkdir(exist_ok=True)
    for r in range(ROWS):
        for c in range(COLS):
            sheet.crop((c * FW, r * FH, (c + 1) * FW, (r + 1) * FH)).save(
                frames_dir / f"frame_r{r:02d}_c{c:02d}.png", "PNG"
            )

    builtin = ROOT / "pets" / "builtin"
    builtin.mkdir(parents=True, exist_ok=True)
    sheet.save(builtin / "spritesheet.webp", "WEBP", lossless=True)
    print(f"[gen] DONE -> {builtin / 'spritesheet.webp'}", flush=True)


asyncio.run(main())
