#!/usr/bin/env bash
# Arranca ResponseGrid Galápagos en local: Postgres + Redis (Homebrew), API :3000, web :3001.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/logs"
brew services start postgresql@17 >/dev/null
brew services start redis >/dev/null
cd "$ROOT/app"
pkill -f "nest start" 2>/dev/null || true
pkill -f next-server 2>/dev/null || true
nohup pnpm --filter api start:dev > "$ROOT/logs/api.log" 2>&1 &
if [ "${1:-}" = "--rebuild" ]; then pnpm --filter web build; fi
nohup pnpm --filter web start > "$ROOT/logs/web.log" 2>&1 &
echo "Esperando a la API…"
for i in $(seq 1 40); do curl -sf localhost:3000/emergencies >/dev/null && break; sleep 3; done
echo "Listo → http://localhost:3001/e/galapagos-2026   (logs en $ROOT/logs)"
