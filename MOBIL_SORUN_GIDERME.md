# Mobil Cihazda Bağlantı Sorunu Giderme

## 🔴 Hata: "İnternet bağlantısı yok veya sunucu bulunamadı"

Mobil cihazda bu hata alınıyorsa, birkaç olası neden var:

## ✅ Çözüm Adımları

### 1. AndroidManifest.xml Kontrolü ✅
- `android/app/src/main/AndroidManifest.xml` dosyasına INTERNET permission eklendi
- APK'yı yeniden build etmeniz gerekiyor

### 2. Domain Kontrolü

#### A. Tarayıcıdan Test Edin
Mobil cihazınızın tarayıcısında (Chrome/Safari):
1. `https://proje.cloud/calisbenimle/api/test.php` adresini açın
2. **JSON görüyorsanız:** ✅ Domain çalışıyor
3. **Hata görüyorsanız:** ❌ Domain sorunu var

#### B. DNS Kontrolü
- Hostinger kontrol panelinde domain'in aktif olduğundan emin olun
- DNS ayarlarının doğru olduğundan emin olun
- DNS yayılımı 24-48 saat sürebilir

### 3. HTTPS/HTTP Test

Eğer HTTPS çalışmıyorsa, geçici olarak HTTP ile test edebilirsiniz:

**`lib/services/api_service.dart` dosyasında:**
```dart
// HTTPS (Önerilen):
static const String baseUrl = 'https://proje.cloud/calisbenimle/api';

// HTTP (Geçici test için):
// static const String baseUrl = 'http://proje.cloud/calisbenimle/api';
```

**ÖNEMLİ:** HTTP sadece test için. Production'da HTTPS kullanın!

### 4. APK'yı Yeniden Build Etme

AndroidManifest.xml değişikliğinden sonra:

1. **Terminal'de:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

2. **Veya Android Studio'da:**
   - Build → Clean Project
   - Build → Rebuild Project
   - Build → Build Bundle(s) / APK(s) → Build APK(s)

3. Yeni APK'yı telefona yükleyin

### 5. İnternet Bağlantısı Kontrolü

Mobil cihazınızda:
- WiFi veya mobil veri açık mı?
- Diğer uygulamalar internet'e bağlanabiliyor mu?
- Tarayıcıdan `https://proje.cloud` açılabiliyor mu?

### 6. SSL Sertifikası Sorunu

Eğer HTTPS kullanıyorsanız:
- Hostinger kontrol panelinde SSL sertifikasının kurulu olduğundan emin olun
- Let's Encrypt SSL ücretsiz kurulabilir
- SSL sertifikası geçersizse, geçici olarak HTTP kullanabilirsiniz

## 📝 Kontrol Listesi

- [ ] AndroidManifest.xml'de INTERNET permission var mı? ✅ (Eklendi)
- [ ] APK yeniden build edildi mi?
- [ ] Mobil cihazda tarayıcıdan domain açılabiliyor mu?
- [ ] DNS ayarları doğru mu?
- [ ] SSL sertifikası kurulu mu?
- [ ] İnternet bağlantısı çalışıyor mu?

## 🆘 Hala Çalışmıyorsa

### Geçici Çözüm: HTTP Kullanın

1. `lib/services/api_service.dart` dosyasını açın
2. API URL'i HTTP olarak değiştirin:
   ```dart
   static const String baseUrl = 'http://proje.cloud/calisbenimle/api';
   ```
3. APK'yı yeniden build edin
4. Test edin

**UYARI:** HTTP güvenli değildir, sadece test için kullanın!

### Alternatif: IP Adresi (Önerilmez)

Hostinger kontrol panelinden IP adresini alıp geçici olarak kullanabilirsiniz, ama bu production için uygun değildir.

## ✅ Başarılı Olduktan Sonra

1. HTTPS'i aktif edin
2. SSL sertifikasını kurun
3. Production APK'yı build edin
4. Test edin

## 🎯 Önerilen Sıra

1. ✅ AndroidManifest.xml'e INTERNET permission ekle (Yapıldı)
2. APK'yı yeniden build et
3. Mobil cihazda tarayıcıdan domain'i test et
4. DNS ayarlarını kontrol et
5. SSL sertifikasını kontrol et
6. Uygulamayı test et

