# 📥 قائمة النماذج الموصى بها — رفيق المبرمج المحترف

> حمّل **واحداً فقط** من هذه الخيارات إلى مجلد `models/` (أو شغّل `SETUP` ليقوم بذلك تلقائياً).
> جميع الروابط من Hugging Face وصيغة الملفات GGUF جاهزة للاستخدام المباشر.

## الخيارات

| الخيار | الحجم | RAM | لماذا؟ |
|---|---|---|---|
| **Qwen3-Coder-30B-A3B — الموصى به** | 17.3 GB | 24GB RAM (أو 16GB + GPU) | الأقوى: بنية MoE بـ 3B معاملات فعالة — سرعة عالية حتى على المعالج، جودة قريبة من النماذج الكبيرة |
| **Qwen2.5-Coder-14B — التوازن** | 8.4 GB | 12GB+ RAM | خيار ممتاز للأجهزة المتوسطة — من أفضل نماذج البرمجة مفتوحة المصدر |
| **Qwen2.5-Coder-7B — الخفيف** | 4.4 GB | 6-8GB RAM | سريع وموثوق للمهام اليومية: دوال، سكربتات، استفسارات سريعة |

**روابط التنزيل المباشرة:**
- [Qwen3-Coder-30B-A3B — الموصى به](https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF) ← `models/Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf`
- [Qwen2.5-Coder-14B — التوازن](https://huggingface.co/unsloth/Qwen2.5-Coder-14B-Instruct-GGUF) ← `models/Qwen2.5-Coder-14B-Instruct-Q4_K_M.gguf`
- [Qwen2.5-Coder-7B — الخفيف](https://huggingface.co/unsloth/Qwen2.5-Coder-7B-Instruct-GGUF) ← `models/Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf`

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
1. دعم قوي للعربية (نماذج Qwen-Coder تدعم العربية والإنجليزية معاً)
2. كمية Instruct/Chat (وليس Base) حتى يفهم المحادثة
3. كمّ Q4_K_M أو Q6_K للتوازن (انظر `docs/TECHNICAL.md` قسم 3)
