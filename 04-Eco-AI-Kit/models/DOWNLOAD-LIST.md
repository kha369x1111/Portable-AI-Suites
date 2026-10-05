# 📥 قائمة النماذج الموصى بها — المساعد الشامل المتنقل

> حمّل **واحداً فقط** من هذه الخيارات إلى مجلد `models/` (أو شغّل `SETUP` ليقوم بذلك تلقائياً).
> جميع الروابط من Hugging Face وصيغة الملفات GGUF جاهزة للاستخدام المباشر.

## الخيارات

| الخيار | الحجم | RAM | لماذا؟ |
|---|---|---|---|
| **Llama-3.2-3B-Instruct — الموصى به** | 1.9 GB | 4GB RAM | الخيار الأساسي: سريع ودقيق لأجهزة 4-8GB بدون كرت شاشة |
| **Qwen2.5-3B-Instruct — عربي أقوى** | 2.0 GB | 4GB RAM | أفضل قليلاً في العربية والصينية — خيار ممتاز للمحتوى العربي |
| **Llama-3.2-1B-Instruct — فائق الخفة** | 0.8 GB | 2GB RAM | للأجهزة القديمة جداً والهواتف/الحواسيب الصغيرة — سرعة فورية |

**روابط التنزيل المباشرة:**
- [Llama-3.2-3B-Instruct — الموصى به](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF) ← `models/Llama-3.2-3B-Instruct-Q4_K_M.gguf`
- [Qwen2.5-3B-Instruct — عربي أقوى](https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF) ← `models/qwen2.5-3b-instruct-q4_k_m.gguf`
- [Llama-3.2-1B-Instruct — فائق الخفة](https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF) ← `models/Llama-3.2-1B-Instruct-Q4_K_M.gguf`

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
1. دعم قوي للعربية (Llama-3.2 وQwen2.5 يقدمان عربية جيدة جداً في هذه الفئة الحجمية)
2. كمية Instruct/Chat (وليس Base) حتى يفهم المحادثة
3. كمّ Q4_K_M أو Q6_K للتوازن (انظر `docs/TECHNICAL.md` قسم 3)
