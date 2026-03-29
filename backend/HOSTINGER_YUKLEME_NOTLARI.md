# Hostinger'a Yükleme Notları

## ✅ Yapılacaklar

### 1. Dosyaları Yükleme
Tüm `backend/` klasöründeki dosyaları Hostinger'ın `public_html/calisbenimle/api/` klasörüne yükleyin:

**Yüklenecek Dosyalar:**
- ✅ `config.php` (GÜNCELLENDİ - Hostinger veritabanı bilgileri)
- ✅ `register.php`
- ✅ `login.php`
- ✅ `logout.php`
- ✅ `save_session.php`
- ✅ `get_sessions.php`
- ✅ `get_weekly_stats.php`
- ✅ `get_topic_progress.php`
- ✅ `get_study_days.php`
- ✅ `toggle_topic.php`
- ✅ `.htaccess` (GÜNCELLENDİ - Hostinger için basitleştirildi)
- ✅ `test.php` (Test için)
- ✅ `database.sql` (Veritabanı şeması - zaten oluşturulmuş)

### 2. Dosya Yolu
Hostinger'da dosyalar şu yolda olmalı:
```
public_html/
  └── calisbenimle/
      └── api/
          ├── config.php
          ├── register.php
          ├── login.php
          ├── ... (diğer PHP dosyaları)
          └── .htaccess
```

### 3. Veritabanı Bilgileri
✅ Veritabanı zaten oluşturulmuş:
- **Veritabanı adı:** `u499931761_calisbenimle`
- **Kullanıcı adı:** `u499931761_atakan`
- **Şifre:** `Atakan987.?`
- **Host:** `localhost` (Hostinger'da genellikle localhost)

### 4. Domain ve API URL
- **Domain:** `proje.cloud`
- **API URL:** `https://proje.cloud/calisbenimle/api`
- ✅ Frontend'de API URL güncellendi

### 5. SSL Sertifikası
Hostinger'da SSL sertifikası kurulu olmalı. Kontrol edin:
- Hostinger kontrol panelinde SSL durumunu kontrol edin
- Let's Encrypt SSL ücretsiz kurulabilir

## 🔧 Yapılan Değişiklikler

### Backend (config.php)
1. ✅ Veritabanı bilgileri Hostinger'a göre güncellendi
2. ✅ Output buffering kodları basitleştirildi (Hostinger'da gerek yok)
3. ✅ `cleanOutputAndSend()` fonksiyonu basitleştirildi

### Frontend (api_service.dart)
1. ✅ API URL `https://proje.cloud/calisbenimle/api` olarak güncellendi
2. ✅ HTTPS kullanılıyor

### .htaccess
1. ✅ InfinityFree özel ayarları kaldırıldı
2. ✅ Hostinger için basitleştirildi

## 📝 Test Adımları

### 1. Test Dosyasını Kontrol Edin
Tarayıcıda açın: `https://proje.cloud/calisbenimle/api/test.php`

**Beklenen Sonuç:**
```json
{
  "success": true,
  "message": "Test başarılı - Hostinger API çalışıyor",
  "timestamp": "2024-...",
  "server": "proje.cloud",
  "method": "GET",
  "hosting": "Hostinger"
}
```

✅ Sadece JSON görüyorsanız: Başarılı!
❌ HTML/JavaScript görüyorsanız: Sorun var, kontrol edin

### 2. Veritabanı Bağlantısını Test Edin
`config.php` dosyasında veritabanı bilgileri doğru mu kontrol edin.

### 3. Uygulamayı Test Edin
1. Flutter uygulamasını çalıştırın
2. Kayıt olmayı deneyin
3. Giriş yapmayı deneyin

## ⚠️ Önemli Notlar

1. **Veritabanı Host:**
   - Hostinger'da genellikle `localhost` kullanılır
   - Eğer farklı bir host verildiyse `config.php`'de güncelleyin

2. **Dosya İzinleri:**
   - Klasörler: `755`
   - PHP dosyaları: `644`
   - `.htaccess`: `644`

3. **SSL Sertifikası:**
   - Hostinger kontrol panelinden SSL'i aktifleştirin
   - Let's Encrypt ücretsiz kurulabilir

4. **Veritabanı Tabloları:**
   - Veritabanı oluşturulmuş
   - Tabloları `database.sql` dosyasından oluşturun (phpMyAdmin'den)

## 🆘 Sorun Giderme

### Veritabanı Bağlantı Hatası
- `config.php`'deki veritabanı bilgilerini kontrol edin
- Hostinger kontrol panelinden veritabanı bilgilerini doğrulayın
- Host değeri `localhost` olmalı (veya Hostinger'ın verdiği değer)

### API Çalışmıyor
- `.htaccess` dosyasının doğru yerde olduğundan emin olun
- Dosya izinlerini kontrol edin
- PHP sürümünü kontrol edin (7.4+ önerilir)

### HTTPS Çalışmıyor
- Hostinger kontrol panelinde SSL sertifikasını kontrol edin
- Let's Encrypt SSL kurun
- Domain'in SSL ile aktif olduğundan emin olun

## ✅ Kontrol Listesi

- [ ] Tüm PHP dosyaları `public_html/calisbenimle/api/` klasörüne yüklendi
- [ ] `.htaccess` dosyası yüklendi
- [ ] `test.php` dosyası test edildi (sadece JSON dönüyor mu?)
- [ ] Veritabanı tabloları oluşturuldu (`database.sql`)
- [ ] SSL sertifikası aktif
- [ ] Uygulama test edildi (kayıt/giriş çalışıyor mu?)

## 🎉 Başarı!

Hostinger'da proje sorunsuz çalışmalı. Herhangi bir sorun olursa yukarıdaki adımları kontrol edin.

