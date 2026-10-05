#!/usr/bin/env bash
# إيقاف محرك DevCompanion
cd "$(dirname "$0")" || exit 1
PORT=8802
if [ -f config/settings.conf ]; then
  P=$(grep -E '^PORT=' config/settings.conf | tail -1 | cut -d= -f2 | tr -d ' \r')
  [ -n "$P" ] && PORT="$P"
fi
echo "إيقاف محرك DevCompanion على المنفذ $PORT ..."
PID=""
[ -f logs/engine.pid ] && PID=$(cat logs/engine.pid 2>/dev/null)
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
  kill "$PID" && echo "[OK] أوقفت المحرك (PID $PID)"
else
  PID=""
  command -v lsof >/dev/null 2>&1 && PID=$(lsof -ti tcp:"$PORT" -sTCP:LISTEN 2>/dev/null | head -1)
  if [ -n "$PID" ]; then
    kill "$PID" && echo "[OK] أوقفت المحرك (PID $PID)"
  else
    echo "[i] لا يوجد محرك يعمل على المنفذ $PORT"
  fi
fi
rm -f logs/engine.pid
