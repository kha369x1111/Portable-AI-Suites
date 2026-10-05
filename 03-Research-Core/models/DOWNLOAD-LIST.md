# 📥 قائمة النماذج الموصى بها — النواة البحثية غير المقيدة

> حمّل **واحداً فقط** من هذه الخيارات إلى مجلد `models/` (أو شغّل `SETUP` ليقوم بذلك تلقائياً).
> جميع الروابط من Hugging Face وصيغة الملفات GGUF جاهزة للاستخدام المباشر.

## الخيارات

| الخيار | الحجم | RAM | لماذا؟ |
|---|---|---|---|
| **Huihui-Qwen3.8-27B-abliterated — الموصى به** | 15.4 GB | 32GB RAM (أو 16GB + GPU 16GB) | الأعمق والأوسع معرفة — نقاش فلسفي وتاريخي رفيع المستوى بالعربية والإنجليزية |
| **Qwen3-14B-abliterated — المتوسط** | 8.4 GB | 12GB+ RAM | توازن جيد بين العمق والسرعة |
| **Qwen3-8B-abliterated — الخفيف** | 4.7 GB | 8GB RAM | للأجهزة المتوسطة — حديث حر بجودة جيدة |

**روابط التنزيل المباشرة:**
- [Huihui-Qwen3.8-27B-abliterated — الموصى به](https://huggingface.co/huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF) ← `models/Huihui-Qwen3.8-27B-abliterated-UD-DW-Q4_K_M.gguf`
- [Qwen3-14B-abliterated — المتوسط](https://huggingface.co/bartowski/mlabonne_Qwen3-14B-abliterated-GGUF) ← `models/mlabonne_Qwen3-14B-abliterated-Q4_K_M.gguf`
- [Qwen3-8B-abliterated — الخفيف](https://huggingface.co/bartowski/mlabonne_Qwen3-8B-abliterated-GGUF) ← `models/mlabonne_Qwen3-8B-abliterated-Q4_K_M.gguf`

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
1. دعم قوي للعربية (نماذج Qwen المعدلة هي الأفضل حالياً للثنائية العربية-الإنجليزية)
2. كمية Instruct/Chat (وليس Base) حتى يفهم المحادثة
3. كمّ Q4_K_M أو Q6_K للتوازن (انظر `docs/TECHNICAL.md` قسم 3)
