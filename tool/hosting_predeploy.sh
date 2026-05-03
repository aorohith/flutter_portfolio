#!/usr/bin/env bash
# Ensures Hosting deploys always bundle CONTACT_FORM_ENDPOINT from dart_defines.json.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

DEFINES="$ROOT/dart_defines.json"
if [[ ! -f "$DEFINES" ]]; then
  echo "hosting_predeploy: missing dart_defines.json — copy dart_defines.example.json and set CONTACT_FORM_ENDPOINT." >&2
  exit 1
fi

python3 <<'PY'
import json
import sys
from pathlib import Path

path = Path("dart_defines.json")
data = json.loads(path.read_text(encoding="utf-8"))
endpoint = (data.get("CONTACT_FORM_ENDPOINT") or "").strip()
if not endpoint:
    print("hosting_predeploy: CONTACT_FORM_ENDPOINT is empty in dart_defines.json.", file=sys.stderr)
    sys.exit(1)
placeholder = "https://formspree.io/f/yourFormId"
if endpoint == placeholder:
    print(f"hosting_predeploy: replace placeholder Formspree URL in dart_defines.json (still {placeholder!r}).", file=sys.stderr)
    sys.exit(1)
PY

exec flutter build web --release --dart-define-from-file=dart_defines.json
