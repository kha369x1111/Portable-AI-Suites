# ==================================================
#  EcoAI — SETUP.ps1
#  إعداد لمرة واحدة (يتطلب إنترنت): تنزيل المحرك + النموذج
#  بعدها يعمل المنتج بالكامل دون أي اتصال.
# ==================================================
$ErrorActionPreference = "Stop"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

function Write-Step($m){ Write-Host "" ; Write-Host $m -ForegroundColor Cyan }
function Write-Ok($m){   Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Wrn($m){  Write-Host "  [!]  $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  EcoAI — المساعد الشامل المتنقل" -ForegroundColor White
Write-Host "  Eco-AI Portable Kit" -ForegroundColor DarkGray
Write-Host ""

# ------------------------------------------------
# الخطوة 1: المحرك (llama.cpp)
# ------------------------------------------------
Write-Step "[1/2] Engine (llama.cpp)"

$engineReady = Test-Path "bin\win\llama-server.exe"
if ($engineReady) {
  Write-Wrn "Engine already exists: bin\win\llama-server.exe"
  $a = Read-Host "      Download a fresh build anyway? (y/N)"
  $engineReady = ($a -notmatch '^[yY]')
}

if (-not $engineReady) {
  Write-Host "  Select build type:" -ForegroundColor White
  Write-Host "    1) CPU        - safest, works on any PC (slower)"
  Write-Host "    2) Vulkan     - GPU acceleration, any modern GPU"
  Write-Host "    3) CUDA 12.4  - NVIDIA GPUs only (fastest)"
  $kind = "cpu"
  switch (Read-Host "  Choice [1-3] (default 1)") {
    "2" { $kind = "vulkan" }
    "3" { $kind = "cuda-12.4" }
    default { $kind = "cpu" }
  }
  $armHint = ""
  if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { $armHint = "(ARM64 Windows detected - you may need the cpu-arm64 build manually)" }

  Write-Host "  Finding latest llama.cpp build..." -ForegroundColor DarkGray
  $rel = Invoke-RestMethod "https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=10" |
         Where-Object { $_.prerelease } | Select-Object -First 1
  if (-not $rel) { throw "Could not reach GitHub - check internet connection." }
  $tag = $rel.tag_name

  $asset = $rel.assets | Where-Object { $_.name -like "*-win-$kind-x64.zip" -and $_.name -notlike "cudart*" } | Select-Object -First 1
  if (-not $asset) { throw "No asset matching *-win-$kind-x64.zip in release $tag" }
  $sizeMB = [math]::Round($asset.size / 1MB)

  New-Item -ItemType Directory -Force -Path "bin\win" | Out-Null
  $zip = "bin\_engine_download.zip"
  Write-Host "  Downloading $($asset.name)  (~$sizeMB MB) ..." -ForegroundColor DarkGray
  curl.exe -L --progress-bar -o $zip $asset.browser_download_url
  if ($LASTEXITCODE -ne 0) { throw "Download failed (curl exit $LASTEXITCODE)" }

  Write-Host "  Extracting to bin\win\ ..." -ForegroundColor DarkGray
  Expand-Archive -Path $zip -DestinationPath "bin\win" -Force
  Remove-Item $zip -Force

  # حزمة CUDA تحتاج مكتبات التشغيل أيضاً
  if ($kind -like "cuda*") {
    $cudart = $rel.assets | Where-Object { $_.name -like "cudart*-$kind-x64.zip" } | Select-Object -First 1
    if ($cudart) {
      $cz = "bin\_cudart.zip"
      Write-Host "  Downloading CUDA runtime ($($cudart.name)) ..." -ForegroundColor DarkGray
      curl.exe -L --progress-bar -o $cz $cudart.browser_download_url
      Expand-Archive -Path $cz -DestinationPath "bin\win" -Force
      Remove-Item $cz -Force
    }
  }

  if (-not (Test-Path "bin\win\llama-server.exe")) { throw "llama-server.exe not found after extraction. $armHint" }
  Write-Ok "Engine installed (llama.cpp build $tag)"
}

# ------------------------------------------------
# الخطوة 2: النموذج
# ------------------------------------------------
Write-Step "[2/2] Model (GGUF)"

$models = @(
  @{ name="Llama-3.2-3B-Instruct — الموصى به"; repo="bartowski/Llama-3.2-3B-Instruct-GGUF"; file="Llama-3.2-3B-Instruct-Q4_K_M.gguf"; gb=1.9; ram="4GB RAM"; note="الخيار الأساسي: سريع ودقيق لأجهزة 4-8GB بدون كرت شاشة" }
  @{ name="Qwen2.5-3B-Instruct — عربي أقوى"; repo="Qwen/Qwen2.5-3B-Instruct-GGUF"; file="qwen2.5-3b-instruct-q4_k_m.gguf"; gb=2.0; ram="4GB RAM"; note="أفضل قليلاً في العربية والصينية — خيار ممتاز للمحتوى العربي" }
  @{ name="Llama-3.2-1B-Instruct — فائق الخفة"; repo="bartowski/Llama-3.2-1B-Instruct-GGUF"; file="Llama-3.2-1B-Instruct-Q4_K_M.gguf"; gb=0.8; ram="2GB RAM"; note="للأجهزة القديمة جداً والهواتف/الحواسيب الصغيرة — سرعة فورية" }
)

Write-Host "  Select a model to download into models\ :" -ForegroundColor White
for ($i = 0; $i -lt $models.Count; $i++) {
  $m = $models[$i]
  Write-Host ("    {0}) {1}  (~{2} GB, needs {3})" -f ($i+1), $m.name, $m.gb, $m.ram)
  Write-Host ("        {0}" -f $m.note) -ForegroundColor DarkGray
}
$sel = Read-Host "  Choice [1-$($models.Count)] (default 1)"
$idx = 0
try { $idx = [int]$sel - 1 } catch { $idx = 0 }
if ($idx -lt 0 -or $idx -ge $models.Count) { $idx = 0 }
$m = $models[$idx]

New-Item -ItemType Directory -Force -Path "models" | Out-Null
$dest = "models\" + $m.file
if ((Test-Path $dest) -and ((Get-Item $dest).Length -gt 100MB)) {
  Write-Wrn "$($m.file) already exists."
  $a = Read-Host "      Download again / verify? (y/N)"
  if ($a -notmatch '^[yY]') { Write-Ok "Keeping existing model file"; $m = $null }
}

if ($m) {
  $url = "https://huggingface.co/$($m.repo)/resolve/main/$($m.file)"
  Write-Host "  Downloading $($m.name) ..." -ForegroundColor DarkGray
  Write-Host "  $url" -ForegroundColor DarkGray
  Write-Host "  (resume supported - if interrupted, run SETUP again)" -ForegroundColor DarkGray
  curl.exe -L -C - -o $dest $url
  if ($LASTEXITCODE -ne 0) { throw "Download failed (curl exit $LASTEXITCODE)" }
  $gbNow = [math]::Round((Get-Item $dest).Length / 1GB, 2)
  if ($gbNow -lt ($m.gb * 0.9)) { Write-Wrn "File size ($gbNow GB) looks smaller than expected (~$($m.gb) GB) - re-run SETUP to resume" }
  else { Write-Ok "Model saved: models\$($m.file)  ($gbNow GB)" }
}

# ------------------------------------------------
# جاهز
# ------------------------------------------------
Write-Host ""
Write-Host "  ==================================================" -ForegroundColor Green
Write-Host "   SETUP COMPLETE / اكتمل الإعداد" -ForegroundColor Green
Write-Host "   الآن افصل الإنترنت إن أردت، ثم شغّل:" -ForegroundColor Green
Write-Host "   ->  START-Windows.bat" -ForegroundColor White
Write-Host "  ==================================================" -ForegroundColor Green
Write-Host ""
