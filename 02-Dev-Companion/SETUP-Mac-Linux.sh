#!/usr/bin/env bash
# ==================================================
#  DevCompanion — SETUP (macOS / Linux)
#  إعداد لمرة واحدة (يتطلب إنترنت): تجهيز المحرك + تنزيل النموذج
#  الاستخدام:  bash SETUP-Mac-Linux.sh
# ==================================================
set -u
cd "$(dirname "$0")" || exit 1

OS=$(uname -s); ARCH=$(uname -m)
if [ "$OS" = "Darwin" ]; then SUB=macos; else SUB=linux; fi

echo
echo "=================================================="
echo "  DevCompanion — رفيق المبرمج المحترف"
echo "  SETUP (run once / يشغَّل مرة واحدة بوجود إنترنت)"
echo "  OS: $OS ($ARCH)"
echo "=================================================="
echo

# ==================================================
# [1/2] المحرك
# ==================================================
if [ -f "bin/$SUB/llama-server" ]; then
  echo "[i] المحرك موجود مسبقاً: bin/$SUB/llama-server"
  read -r -p "    تنزيل/بناء نسخة جديدة رغم ذلك؟ (y/N) " a
  case "$a" in y|Y) ;; *) skip_engine=1 ;; esac
fi

if [ "${skip_engine:-0}" != "1" ]; then
  if [ "$OS" = "Darwin" ]; then
    echo
    echo "اختر طريقة تجهيز المحرك على macOS:"
    echo "  1) Homebrew   — الأسرع (يتطلب brew على هذا الجهاز؛ الواجهة ستعمل"
    echo "                  مباشرة على الأجهزة التي عليها brew)"
    echo "  2) بناء من المصدر — الأفضل للنقل: ملف ثابت واحد يعمل على أي ماك"
    echo "     (يتطلب أدوات Xcode: xcode-select --install)"
    read -r -p "الاختيار [1-2] (الافتراضي 1): " ch
    if [ "$ch" = "2" ]; then
      BUILD_FROM_SOURCE=1
    else
      if ! command -v brew >/dev/null 2>&1; then
        echo "[X] لم أجد Homebrew. ثبّته من https://brew.sh ثم أعد المحاولة،"
        echo "    أو اختر البناء من المصدر (الخيار 2)."
        exit 1
      fi
      echo "[..] brew install llama.cpp  (أو تحديثه إن كان مثبتاً)"
      brew install llama.cpp 2>/dev/null || brew upgrade llama.cpp
      SRCPATH="$(brew --prefix llama.cpp 2>/dev/null)/bin/llama-server"
      if [ ! -f "$SRCPATH" ]; then
        for d in /opt/homebrew/bin/llama-server /usr/local/bin/llama-server; do
          [ -f "$d" ] && SRCPATH="$d" && break
        done
      fi
      [ -f "$SRCPATH" ] || { echo "[X] تعذر إيجاد llama-server بعد التثبيت"; exit 1; }
      mkdir -p "bin/$SUB"
      cp "$SRCPATH" "bin/$SUB/llama-server"
      echo "[OK] نُسخ المحرك إلى bin/$SUB/llama-server"
      echo "[i] ملاحظة: نسخة brew تعتمد على مكتبات الجهاز — لنقلها إلى ماك آخر"
      echo "    بلا brew استخدم البناء من المصدر (الخيار 2)."
    fi
  else
    echo "[i] على لينكس يُبنى المحرك من المصدر (ملف ثابت واحد)."
    BUILD_FROM_SOURCE=1
  fi

  if [ "${BUILD_FROM_SOURCE:-0}" = "1" ]; then
    echo
    miss=""
    command -v git   >/dev/null 2>&1 || miss="$miss git"
    command -v cmake >/dev/null 2>&1 || miss="$miss cmake"
    command -v cc    >/dev/null 2>&1 || miss="$miss cc(gcc/clang)"
    if [ -n "$miss" ]; then
      echo "[X] أدوات ناقصة:$miss"
      if [ "$OS" = "Darwin" ]; then
        echo "    ثبّتها ب:  xcode-select --install   ثم   brew install cmake"
      else
        echo "    على Debian/Ubuntu:  sudo apt install -y git build-essential cmake"
        echo "    على Fedora:         sudo dnf install -y git gcc-c++ make cmake"
      fi
      exit 1
    fi
    NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
    WORK=$(mktemp -d)
    echo "[..] تنزيل مصدر llama.cpp وبناء llama-server (قد يستغرق 5-15 دقيقة)..."
    git clone --depth 1 https://github.com/ggml-org/llama.cpp "$WORK/llama.cpp" || { echo "[X] فشل git clone"; exit 1; }
    cmake -S "$WORK/llama.cpp" -B "$WORK/build" \
      -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
      -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF \
      > /dev/null || { echo "[X] فشل تهيئة البناء"; exit 1; }
    cmake --build "$WORK/build" --target llama-server -j"$NPROC" > /dev/null || { echo "[X] فشل البناء"; exit 1; }
    mkdir -p "bin/$SUB"
    cp "$WORK/build/bin/llama-server" "bin/$SUB/llama-server" || { echo "[X] لم أجد ناتج البناء"; exit 1; }
    chmod +x "bin/$SUB/llama-server"
    rm -rf "$WORK"
    echo "[OK] بُني المحرك ونُسخ إلى bin/$SUB/llama-server (ملف ثابت مستقل)"
  fi
fi

# ==================================================
# [2/2] النموذج
# ==================================================
echo
echo "اختر النموذج المطلوب تنزيله إلى models/ :"
echo
NAMES=()
URLS=()
FILES=()
RAMS=()
GBS=()
NOTES=()
BYTES=()
NAMES+=("Qwen3-Coder-30B-A3B — الموصى به")
GBS+=(17.3)
RAMS+=("24GB RAM (أو 16GB + GPU)")
NOTES+=("الأقوى: بنية MoE بـ 3B معاملات فعالة — سرعة عالية حتى على المعالج، جودة قريبة من النماذج الكبيرة")
URLS+=("https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF/resolve/main/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf")
FILES+=("Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf")
BYTES+=(18556649472)

NAMES+=("Qwen2.5-Coder-14B — التوازن")
GBS+=(8.4)
RAMS+=("12GB+ RAM")
NOTES+=("خيار ممتاز للأجهزة المتوسطة — من أفضل نماذج البرمجة مفتوحة المصدر")
URLS+=("https://huggingface.co/unsloth/Qwen2.5-Coder-14B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf")
FILES+=("Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf")
BYTES+=(8987344896)

NAMES+=("Qwen2.5-Coder-7B — الخفيف")
GBS+=(4.4)
RAMS+=("6-8GB RAM")
NOTES+=("سريع وموثوق للمهام اليومية: دوال، سكربتات، استفسارات سريعة")
URLS+=("https://huggingface.co/unsloth/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf")
FILES+=("Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf")
BYTES+=(4682940416)

i=1
for n in "${NAMES[@]}"; do
  echo "  $i) $n  (~${GBS[$((i-1))]} GB — يحتاج ${RAMS[$((i-1))]})"
  echo "      ${NOTES[$((i-1))]}"
  i=$((i+1))
done
echo
read -r -p "الاختيار [1-$((i-1))] (الافتراضي 1): " sel
case "$sel" in
  ''|*[!0-9]*) sel=1 ;;
esac
[ "$sel" -ge 1 ] 2>/dev/null || sel=1
[ "$sel" -le "${#NAMES[@]}" ] 2>/dev/null || sel=1
idx=$((sel-1))

mkdir -p models
FILE="${FILES[$idx]}"
URL="${URLS[$idx]}"
if [ -f "models/$FILE" ] && [ "$(stat -c%s "models/$FILE" 2>/dev/null || stat -f%z "models/$FILE")" -gt 100000000 ]; then
  echo "[i] الملف موجود مسبقاً: models/$FILE"
  read -r -p "    إعادة التنزيل/الاستكمال؟ (y/N) " a
  case "$a" in y|Y) ;; *) echo "[OK] أبقينا الملف الحالي"; FILE="" ;; esac
fi

if [ -n "$FILE" ]; then
  echo "[..] تنزيل ${NAMES[$idx]}"
  echo "     $URL"
  echo "     (يدعم الاستكمال — إن انقطع أعد تشغيل SETUP)"
  curl -L -C - --progress-bar -o "models/$FILE" "$URL" || echo "[!] انقطع التنزيل — أعد تشغيل SETUP للاستكمال"
  EXPECT="${BYTES[$idx]}"
  ACTUAL=$(stat -c%s "models/$FILE" 2>/dev/null || stat -f%z "models/$FILE" 2>/dev/null || echo 0)
  if [ "$ACTUAL" -lt "$((EXPECT * 95 / 100))" ]; then
    echo "[!] الملف ناقص ($ACTUAL من $EXPECT بايت) — أعد تشغيل SETUP للاستكمال"
  else
    echo "[OK] حُفظ النموذج كاملاً: models/$FILE ($ACTUAL بايت)"
  fi
fi

echo
echo "=================================================="
echo " اكتمل الإعداد — الآن يمكن فصل الإنترنت تماماً"
echo " للتشغيل:  bash START-Mac-Linux.sh"
echo "=================================================="
