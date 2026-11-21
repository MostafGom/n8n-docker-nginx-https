#!/usr/bin/env bash
# Creates .env from .env.example and fills in random secrets.
# Will not overwrite an existing .env (that would lock you out of your saved credentials).
set -euo pipefail
cd "$(dirname "$0")"

if [ -e .env ]; then
  echo ".env already exists - leaving it untouched." >&2
  echo "Delete it yourself only if you want to start over with empty data." >&2
  exit 1
fi

random_hex() { head -c 32 /dev/urandom | od -An -tx1 | LC_ALL=C tr -dc '0-9a-f'; }

: > .env.tmp
chmod 600 .env.tmp
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    *=__GENERATED__) printf '%s=%s\n' "${line%%=*}" "$(random_hex)" ;;
    *)               printf '%s\n' "$line" ;;
  esac
done < .env.example >> .env.tmp
mv .env.tmp .env

echo "Created $(pwd)/.env with new random secrets."
echo "Keep this file safe: N8N_ENCRYPTION_KEY is needed to read your saved credentials."
