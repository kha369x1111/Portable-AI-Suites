#!/usr/bin/env bash
# ==================================================
#  EcoAI — المساعد الشامل المتنقل (Eco-AI Portable Kit)
#  التشغيل بنقرة واحدة على macOS / Linux
#  الاستخدام:  bash START-Mac-Linux.sh
# ==================================================
set -u
cd "$(dirname "$0")" || exit 1

# ---------- قراءة الإعدادات ----------
PORT=8804
CTX=4096
GPU=AUTO
THREADS=0
TEMP=0.7
MODEL_FILE=AUTO
EXTRA="--jinja"

if [ -f config/settings.conf ]; then
  while IFS='=' read -r k v; do
    case "$k" in ''|'#'*) continue ;; esac
    case "$k" in
      PORT)         PORT="${v%%$'\r'}" ;;
      CONTEXT_SIZE) CTX="${v%%$'\r'}" ;;
      GPU_LAYERS)   GPU="${v%%$'\r'}" ;;
      THREADS)      THREADS="${v%%$'\r'}" ;;
      TEMPERATURE)  TEMP="${v%%$'\r'}" ;;
      MODEL_FILE)   MODEL_FILE="${v%%$'\r'}" ;;
      EXTRA_ARGS)   EXTRA="${v%%$'\r'}" ;;
    esac
  done < config/settings.conf
fi

# ---------- حماية من القيم الفارغة ----------
[ -z "$PORT" ] && PORT=8804
[ -z "$CTX" ] && CTX=4096
[ -z "$TEMP" ] && TEMP=0.7
[ -z "$THREADS" ] && THREADS=0
[ -z "$MODEL_FILE" ] && MODEL_FILE=AUTO

OS=$(uname -s); ARCH=$(uname -m)
if [ "$OS" = "Darwin" ]; then SUB=macos; else SUB=linux; fi

echo
echo "=================================================="
echo "  EcoAI — المساعد الشامل المتنقل"
echo "  Eco-AI Portable Kit (Offline / Air-Gapped)"
echo "=================================================="
echo

# ---------- البحث عن النموذج ----------
MODEL=""
if [ "$MODEL_FILE" != "AUTO" ] && [ -f "models/$MODEL_FILE" ]; then
  MODEL="$MODEL_FILE"
fi
if [ -z "$MODEL" ]; then
  MODEL=$(ls -S models/*.gguf 2>/dev/null | head -1)
fi
if [ -z "$MODEL" ]; then
  echo "[X] لا يوجد نموذج في مجلد models/"
  echo "    شغّل:  bash SETUP-Mac-Linux.sh   (مرة واحدة، بوجود إنترنت)"
  echo "    أو انسخ أي ملف .gguf إلى مجلد models/"
  exit 1
fi
echo "[+] النموذج : $MODEL"

# ---------- البحث عن المحرك ----------
ENGINE=""
for c in "bin/$SUB/llama-server" "bin/$SUB/llama-server-$ARCH" "bin/llama-server"; do
  if [ -f "$c" ]; then ENGINE="$c"; break; fi
done
if [ -z "$ENGINE" ]; then
  echo "[X] لم أجد محرك llama-server في bin/$SUB/"
  echo "    شغّل:  bash SETUP-Mac-Linux.sh"
  exit 1
fi
echo "[+] المحرك : $ENGINE"

BIN="$ENGINE"
if [ ! -x "$BIN" ]; then
  # نظام ملفات بدون صلاحية تنفيذ (مثل exFAT) — ننسخه لمجلد مؤقت ونمنحه التنفيذ
  TMPBIN="${TMPDIR:-/tmp}/llama-server.$$"
  cp "$BIN" "$TMPBIN" && chmod +x "$TMPBIN" && BIN="$TMPBIN" || { echo "[X] تعذر تجهيز المحرك"; exit 1; }
fi

# ---------- هل المحرك يعمل مسبقاً؟ ----------
if curl -s -m 3 "http://127.0.0.1:$PORT/health" 2>/dev/null | grep -q ok; then
  echo "[i] المحرك يعمل مسبقاً على المنفذ $PORT"
else
  mkdir -p logs
  ARGS=(-m "$MODEL" --host 127.0.0.1 --port "$PORT" -c "$CTX" --temp "$TEMP")
  if [ "$THREADS" -gt 0 ] 2>/dev/null; then ARGS+=(-t "$THREADS"); fi
  if [ "$GPU" = "0" ]; then ARGS+=(-ngl 0); fi
  if [ -n "$EXTRA" ]; then
    read -r -a EXTRA_ARR <<< "$EXTRA"
    ARGS+=("${EXTRA_ARR[@]}")
  fi

  echo "[+] تشغيل المحرك (السياق=$CTX، المنفذ $PORT)..."
  nohup "$BIN" "${ARGS[@]}" > logs/engine.log 2>&1 &
  echo $! > logs/engine.pid

  echo "[..] تحميل النموذج — النماذج الكبيرة قد تستغرق 1-5 دقائق"
  TRIES=0
  while [ "$TRIES" -lt 150 ]; do
    sleep 2
    if curl -s -m 3 "http://127.0.0.1:$PORT/health" 2>/dev/null | grep -q ok; then break; fi
    if ! kill -0 "$(cat logs/engine.pid 2>/dev/null)" 2>/dev/null; then
      echo "[X] توقف المحرك أثناء الإقلاع! آخر سطور السجل:"
      echo "-----------------------------------------"
      tail -n 20 logs/engine.log
      exit 1
    fi
    TRIES=$((TRIES+1))
  done
  if ! curl -s -m 3 "http://127.0.0.1:$PORT/health" 2>/dev/null | grep -q ok; then
    echo "[X] انتهت المهلة (5 دقائق) — راجع logs/engine.log"
    exit 1
  fi
fi
echo "[OK] المحرك جاهز:  http://127.0.0.1:$PORT"

# ---------- فتح الواجهة ----------
printf 'window.LAUNCH_PORT=%s;\n' "$PORT" > ui/port.js
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "ui/index.html" >/dev/null 2>&1 || true
elif [ "$OS" = "Darwin" ]; then
  open "ui/index.html" || true
else
  echo "[i] افتح الملف ui/index.html في متصفحك يدوياً"
fi

echo
echo "  - للإيقاف     : bash STOP-Mac-Linux.sh"
echo "  - سجل المحرك  : logs/engine.log"
echo "  - الواجهة المدمجة البديلة: http://127.0.0.1:$PORT"
echo
