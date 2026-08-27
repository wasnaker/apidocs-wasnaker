#!/usr/bin/env bash
#
# deploy-docs.sh — bantu regenerate dokumentasi API Scribe dari lrvl-wasnaker_core
#                 lalu sync ke folder public/ repo apidocs-wasnaker.
#
# Penggunaan:
#   ./deploy-docs.sh /path/to/wasnaker-core
#   ./deploy-docs.sh /path/to/wasnaker-core --no-push   # generate + commit, tanpa push
#
# Skrip ini dijalankan dari dalam folder repo apidocs-wasnaker.

set -euo pipefail

# --- validasi argumen ---
CORE_DIR="${1:-}"
if [[ -z "$CORE_DIR" || ! -d "$CORE_DIR" ]]; then
  echo "ERROR: path ke wasnaker-core tidak valid." >&2
  echo "Penggunaan: $0 /path/to/wasnaker-core [--no-push]" >&2
  exit 1
fi

NO_PUSH=0
if [[ "${2:-}" == "--no-push" ]]; then
  NO_PUSH=1
fi

API_DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBLIC_DIR="$API_DOCS_DIR/public"

echo ">> Core dir : $CORE_DIR"
echo ">> Docs dir : $API_DOCS_DIR"

# --- 1. generate scribe ---
echo ">> Menjalankan php artisan scribe:generate --force ..."
( cd "$CORE_DIR" && php artisan scribe:generate --force )

# Scribe sudah menulis langsung ke $PUBLIC_DIR (lihat config/scribe.php
# static.output_path). Verifikasi hasil ada.
if [[ ! -f "$PUBLIC_DIR/index.html" ]]; then
  echo "ERROR: index.html tidak ditemukan di $PUBLIC_DIR setelah generate." >&2
  exit 1
fi

# --- 2. git add + commit ---
cd "$API_DOCS_DIR"
echo ">> Staging perubahan ..."
git add public/ README.md deploy-docs.sh 2>/dev/null || git add public/

if git diff --cached --quiet; then
  echo ">> Tidak ada perubahan untuk di-commit."
else
  MSG="docs: regenerate Scribe $(date +%Y-%m-%d_%H:%M:%S)"
  echo ">> Commit: $MSG"
  git commit -m "$MSG"
fi

# --- 3. push ---
if [[ "$NO_PUSH" -eq 1 ]]; then
  echo ">> --no-push: dilewati."
  exit 0
fi

echo ">> Push ke origin/main ..."
git push origin main

echo ">> SELESAI."
