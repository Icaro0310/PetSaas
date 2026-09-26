"""Generate the PetDeskSaas builtin pet using REAL Chrome via CDP.

Why: Google blocks sign-in on Playwright's bundled Chromium, and Chrome
127+ app-bound encryption means the saved profile cookies cannot be read
by Playwright's Chromium. So we launch the user's real Chrome on the
FrameRonin profile (--remote-debugging-port), attach Playwright over CDP,
and run the generation inside the already-authenticated session.

Post-processing reuses frame_ronin_mcp.lib (dewatermark, white_to_alpha,
resize NEAREST, split) -> pets/builtin/spritesheet.webp + frames/.
"""

import asyncio
import base64
import json
import socket
import subprocess
import sys
import time
from pathlib import Path

from playwright.async_api import async_playwright
from PIL import Image

from frame_ronin_mcp.tools.generate import expand_prompt
from frame_ronin_mcp.lib.watermark import remove_gemini_watermark
from frame_ronin_mcp.lib.image_utils import load_image, save_image, white_to_alpha

CHROME = r"C:\Users\Utilizador\AppData\Local\Google\Chrome\Application\chrome.exe"
PROFILE = str(Path.home() / ".frame-ronin-browser")
PORT = 9222
ROOT = Path(__file__).resolve().parent.parent

ROWS, COLS, FW, FH = 4, 4, 48, 48
PROMPT = (
    "cute chubby orange tabby cat mascot, sitting, big friendly eyes, "
    "simple clean silhouette, pixel art"
)


def port_open() -> bool:
    s = socket.socket()
    s.settimeout(0.5)
    try:
        s.connect(("127.0.0.1", PORT))
        return True
    except OSError:
        return False
    finally:
        s.close()


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
    raise TimeoutError(f"Gemini generation timed out ({timeout}s)")


async def main() -> None:
    out = ROOT / "pets" / "builtin-src"
    out.mkdir(parents=True, exist_ok=True)
    raw = out / "01_raw.png"

    if not port_open():
        subprocess.Popen(
            [
                CHROME,
                f"--user-data-dir={PROFILE}",
                f"--remote-debugging-port={PORT}",
                "--disable-session-crashed-bubble",
                "--hide-crash-restore-bubble",
                "https://gemini.google.com/app",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        for _ in range(30):
            if port_open():
                break
            time.sleep(1)
        else:
            print("[gen] ERRO: porta 9222 nao abriu — fecha todas as "
                  "janelas desse Chrome e tenta de novo", flush=True)
            sys.exit(1)

    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp(f"http://127.0.0.1:{PORT}")
        ctx = browser.contexts[0]
        page = next(
            (pg for pg in ctx.pages if "gemini.google.com" in pg.url),
            ctx.pages[0] if ctx.pages else await ctx.new_page(),
        )
        if "gemini.google.com" not in page.url:
            await page.goto(
                "https://gemini.google.com/app",
                wait_until="domcontentloaded",
                timeout=30000,
            )
        await asyncio.sleep(4)

        n_signin = await page.locator(
            'a:has-text("Sign in"), button:has-text("Sign in"),'
            'a:has-text("Iniciar sessão"), button:has-text("Iniciar sessão"),'
            'a:has-text("Iniciar sessao"), button:has-text("Iniciar sessao")'
        ).count()
        print(f"[gen] sign_in buttons: {n_signin}", flush=True)
        if n_signin > 0:
            print("[gen] NAO AUTENTICADO — faz login nessa janela do Chrome "
                  "e corre este script de novo", flush=True)
            sys.exit(2)

        prompt = expand_prompt(PROMPT, style="rpgmaker")
        full = (
            f"{prompt}\nGenerate as a pixel art RPG Maker MV sprite sheet: "
            f"exactly {ROWS} rows x {COLS} columns of {FW}x{FH} pixel frames. "
            f"White background. Clean pixel edges, no anti-aliasing. "
            f"Each frame should be a distinct pose/animation step."
        )
        tb = page.get_by_role("textbox").first
        await tb.wait_for(state="visible", timeout=15000)
        await tb.fill(full)
        await tb.press("Enter")
        print("[gen] prompt enviado — a aguardar imagem…", flush=True)

        await grab_image(page, raw)
        print(f"[gen] imagem -> {raw}", flush=True)
        await browser.close()  # detaches; chrome stays/updates profile

    # post-process (same as FrameRonin rpgmaker pipeline)
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
