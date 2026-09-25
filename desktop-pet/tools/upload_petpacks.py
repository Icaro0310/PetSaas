"""Upload dos .petpack gerados para o bucket Supabase 'petpacks'.

    SUPABASE_SERVICE_ROLE_KEY=... python tools/upload_petpacks.py

O bucket e' privado; o upload precisa da service_role (env). NUNCA
commitar a key — le-se do ambiente. Destino: library/<ficheiro>.petpack
(a policy de leitura do bucket permite a autenticados ler 'library/*').
"""

import os
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "pets" / "petpacks"
SUPABASE_URL = "https://dotplnbakltelacsxvjz.supabase.co"
BUCKET = "petpacks"
PREFIX = "library"


def upload(path: Path, key: str) -> tuple[int, str]:
    url = f"{SUPABASE_URL}/storage/v1/object/{BUCKET}/{PREFIX}/{path.name}"
    req = urllib.request.Request(
        url,
        data=path.read_bytes(),
        method="POST",
        headers={
            "apikey": key,
            "authorization": f"Bearer {key}",
            "content-type": "application/zip",
            "x-upsert": "true",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as res:
            return res.status, res.read().decode()[:200]
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()[:300]


def main() -> None:
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "").strip()
    if not key:
        sys.exit("SUPABASE_SERVICE_ROLE_KEY em falta no ambiente")
    packs = sorted(SRC.glob("*.petpack"))
    if not packs:
        sys.exit(f"sem petpacks em {SRC} — corre pack_petpacks.py primeiro")
    fail = 0
    for p in packs:
        code, body = upload(p, key)
        ok = 200 <= code < 300
        print(f"[{'ok' if ok else 'FAIL'}] {p.name} -> {code} {body if not ok else ''}")
        fail += 0 if ok else 1
    sys.exit(1 if fail else 0)


if __name__ == "__main__":
    main()
