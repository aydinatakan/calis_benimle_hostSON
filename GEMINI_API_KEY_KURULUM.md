# Gemini API Key Kurulum Rehberi

## 🔑 API Key Nasıl Alınır?

### 1. Google AI Studio'ya Giriş Yapın
1. Tarayıcınızda şu adrese gidin: https://aistudio.google.com/app/apikey
2. Google hesabınızla giriş yapın

### 2. API Key Oluşturun
1. **"Create API Key"** veya **"Get API Key"** butonuna tıklayın
2. Yeni bir proje oluşturun veya mevcut bir projeyi seçin
3. API key'iniz oluşturulacak ve gösterilecek
4. **ÖNEMLİ:** API key'i hemen kopyalayın, bir daha gösterilmeyecek!

### 3. API Key'i Projeye Ekleyin

1. Projenizde `lib/services/gemini_service.dart` dosyasını açın
2. 5. satırda şu satırı bulun:
   ```dart
   static const String _apiKey = 'BURAYA_API_KEY_YAZ';
   ```
3. `BURAYA_API_KEY_YAZ` kısmını kendi API key'inizle değiştirin:
   ```dart
   static const String _apiKey = 'AIzaSy...'; // Kendi API key'iniz
   ```

### 4. Örnek
```dart
// ÖNCE (Yanlış):
static const String _apiKey = 'BURAYA_API_KEY_YAZ';

// SONRA (Doğru):
static const String _apiKey = 'AIzaSyD1234567890abcdefghijklmnopqrstuvwxyz';
```

## ⚠️ Güvenlik Uyarıları

### API Key Güvenliği
- ✅ API key'i **ASLA** GitHub veya diğer public repository'lere yüklemeyin
- ✅ API key'i paylaşmayın
- ✅ Eğer yanlışlıkla paylaştıysanız, Google AI Studio'dan eski key'i silin ve yeni bir tane oluşturun

### .gitignore Kontrolü
Projenizin `.gitignore` dosyasında şu satırlar olmalı:
```
# API Keys
lib/services/gemini_service.dart
*.env
.env
```

**NOT:** `gemini_service.dart` dosyasını gitignore'a eklemek yerine, API key'i environment variable olarak kullanmak daha güvenlidir (ileride yapılabilir).

## 🧪 Test

API key'i ekledikten sonra:
1. Uygulamayı yeniden başlatın
2. Chatbot ekranına gidin
3. Bir mesaj gönderin
4. Eğer çalışıyorsa: ✅ Başarılı!
5. Eğer hata alıyorsanız: API key'in doğru kopyalandığından emin olun

## 🆘 Sorun Giderme

### "API anahtarı geçersiz" hatası
- API key'in doğru kopyalandığından emin olun
- Başındaki/sonundaki boşlukları kontrol edin
- Yeni bir API key oluşturmayı deneyin

### "API key yapılandırılmamış" hatası
- `gemini_service.dart` dosyasında API key'in `BURAYA_API_KEY_YAZ` olmadığından emin olun
- API key'in tırnak işaretleri içinde olduğundan emin olun

### Quota/Limit Hatası
- Google AI Studio'da kullanım limitlerinizi kontrol edin
- Ücretsiz plan limitleri: Günde belirli sayıda istek
- Limit aşıldıysa bir sonraki gün bekleyin veya ücretli plana geçin

## 📚 Kaynaklar

- Google AI Studio: https://aistudio.google.com/
- Gemini API Dokümantasyonu: https://ai.google.dev/docs
- API Key Yönetimi: https://aistudio.google.com/app/apikey

## ✅ Kontrol Listesi

- [ ] Google AI Studio'ya giriş yaptım
- [ ] API key oluşturdum
- [ ] API key'i kopyaladım
- [ ] `gemini_service.dart` dosyasında API key'i güncelledim
- [ ] Uygulamayı test ettim
- [ ] Chatbot çalışıyor

