# 📥 قائمة النماذج الموصى بها — حزمة الخصوصية المطلقة

> حمّل **واحداً فقط** من هذه الخيارات إلى مجلد `models/` (أو شغّل `SETUP` ليقوم بذلك تلقائياً).
> جميع الروابط من Hugging Face وصيغة الملفات GGUF جاهزة للاستخدام المباشر.

## الخيارات

| الخيار | الحجم | RAM | لماذا؟ |
|---|---|---|---|
| **Qwen3-14B Instruct — الموصى به** | 8.4 GB | 12GB+ RAM | أدق خيار: فهم ممتاز للعربية والإنجليزية وسياق طويل لتحليل المستندات الكبيرة |
| **Gemma-3-12B-it — بديل متعدد اللغات** | 6.8 GB | 10GB+ RAM | من Google — دعم واسع للغات وسياق 128K |
| **Qwen3-8B — لأجهزة 8-12GB** | 4.7 GB | 8GB RAM | أخف وأسرع مع دقة جيدة للتحليل العام |

**روابط التنزيل المباشرة:**
- [Qwen3-14B Instruct — الموصى به](https://huggingface.co/Qwen/Qwen3-14B-GGUF) ← `models/Qwen3-14B-Q4_K_M.gguf`
- [Gemma-3-12B-it — بديل متعدد اللغات](https://huggingface.co/unsloth/gemma-3-12b-it-GGUF) ← `models/gemma-3-12b-it-Q4_K_M.gguf`
- [Qwen3-8B — لأجهزة 8-12GB](https://huggingface.co/bartowski/Qwen_Qwen3-8B-GGUF) ← `models/Qwen_Qwen3-8B-Q4_K_M.gguf`

## طريقة التنزيل اليدوية

**على جهاز متصل بالإنترنت:**

```bash
# مثال (Linux/macOS):
curl -L -o MODEL-FILE.gguf "https://huggingface.co/REPO/resolve/main/MODEL-FILE.gguf"

# أو على Windows (PowerShell):
curl.exe -L -o MODEL-FILE.gguf "https://huggingface.co/REPO/resolve/main/MODEL-FILE.gguf"
```

ثم انسخ الملف إلى مجلد `models/` في هذا المنتج، وشغّل `START`.

> 💡 `SETUP` يفعل نفس الشيء مع قائمة تفاعلية والتحقق من الحجم — الطريقتان متكافئتان.

## كيف تختار؟

- **RAM 8GB أو أقل:** الخيار الأخف في القائمة.
- **RAM 16GB:** الخيار الأساسي (الصف الأول).
- **RAM 32GB+ أو GPU 16GB+:** اختر الأثقل لجودة أعلى.
- حساب سريع: كل 1GB من ملف النموذج ≈ 1.2GB RAM عند التشغيل (مع السياق الافتراضي).

## بدائل أخرى

أي ملف `.gguf` آخر يعمل أيضاً — انسخه إلى `models/` وشغّل `START`. معايير الاختيار:
1. دعم قوي للعربية (نماذج Qwen وGemma هي الأقوى عربياً حالياً)
2. كمية Instruct/Chat (وليس Base) حتى يفهم المحادثة
3. كمّ Q4_K_M أو Q6_K للتوازن (انظر `docs/TECHNICAL.md` قسم 3)
