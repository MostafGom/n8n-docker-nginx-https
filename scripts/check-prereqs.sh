#!/usr/bin/env bash
# Checks that your machine is ready. Changes nothing. Run it as often as you like:
#   ./scripts/check-prereqs.sh
cd "$(dirname "$0")/.." || exit 1

HOSTS="n8n.apps.mylocalhost n8n-queue.apps.mylocalhost"
fail=0
ok()   { printf '  [ OK ]  %s\n' "$1"; }
bad()  { printf '  [FAIL]  %s\n          -> %s\n' "$1" "$2"; fail=1; }
todo() { printf '  [TODO]  %s\n          -> %s\n' "$1" "$2"; }

echo "Tools"
if command -v docker >/dev/null 2>&1; then
  ok "Docker is installed ($(docker --version 2>/dev/null))"
  if docker info >/dev/null 2>&1; then
    ok "Docker is running"
  else
    bad "Docker is installed but not running (or you lack permission)" \
        "Start Docker Desktop, or on Linux: sudo systemctl start docker (see docs/01-install-docker-linux.md)"
  fi
  if docker compose version >/dev/null 2>&1; then
    ok "Docker Compose v2 is available ($(docker compose version --short 2>/dev/null))"
  else
    bad "The 'docker compose' command is missing" "Install the Docker Compose plugin (docs/01-install-*.md)"
  fi
else
  bad "Docker is not installed" "Follow docs/01-install-docker-<your system>.md"
fi

if command -v mkcert >/dev/null 2>&1; then
  ok "mkcert is installed"
else
  bad "mkcert is not installed" "Follow docs/01-install-docker-<your system>.md"
fi

echo
echo "Setup steps"
if docker network inspect local-shared >/dev/null 2>&1; then
  ok "Docker network 'local-shared' exists"
else
  todo "Docker network 'local-shared' does not exist yet" "docker network create local-shared"
fi

if [ -f nginx/certs/apps.mylocalhost.pem ] && [ -f nginx/certs/apps.mylocalhost-key.pem ]; then
  ok "HTTPS certificate exists in nginx/certs/"
else
  todo "HTTPS certificate not created yet" "./nginx/generate-certs.sh"
fi

for h in $HOSTS; do
  if awk -v h="$h" '{ sub(/#.*/, "") } $1 == "127.0.0.1" { for (i = 2; i <= NF; i++) if ($i == h) found = 1 } END { exit !found }' /etc/hosts 2>/dev/null; then
    ok "hosts file has $h"
  else
    todo "hosts file is missing $h" "see docs/02-https-and-hosts.md"
  fi
done

for f in n8n/.env n8n-queue/.env; do
  if [ -f "$f" ]; then ok "$f exists"; else todo "$f not created yet (only needed for that variant)" "./${f%/.env}/generate-env.sh"; fi
done

echo
echo "Ports"
for port in 80 443; do
  proxy_running=$(docker ps --filter label=com.docker.compose.project=local-proxy --filter "publish=$port" -q 2>/dev/null)
  if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
    if [ -n "$proxy_running" ]; then
      ok "Port $port is in use by this project's nginx"
    else
      bad "Port $port is already used by another program" "Stop that program first (see docs/troubleshooting.md)"
    fi
  else
    ok "Port $port is free"
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "No blockers found. Finish any [TODO] items above, in order."
else
  echo "Fix the [FAIL] items above, then run this check again."
fi
exit "$fail"
