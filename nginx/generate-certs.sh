#!/usr/bin/env bash
# Creates a locally trusted HTTPS certificate for *.apps.mylocalhost
# and saves it in nginx/certs/. Safe to run again.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v mkcert >/dev/null 2>&1; then
  echo "mkcert is not installed. See docs/01-install-*.md for your system." >&2
  exit 1
fi

# Adds mkcert's local certificate authority to your system and browsers.
# May ask for your password the first time.
mkcert -install

mkdir -p certs
mkcert \
  -cert-file certs/apps.mylocalhost.pem \
  -key-file  certs/apps.mylocalhost-key.pem \
  "*.apps.mylocalhost"

echo
echo "Done. Certificate saved in nginx/certs/ (this folder is ignored by git)."
