# Sunucuya Yükleme Notları

## ✅ Yapılacaklar

### 1. Dosyaları Yükleme
Tüm `backend/` klasöründeki dosyaları sunucunun `htdocs/api/` klasörüne yükleyin:

**Yüklenecek Dosyalar:**
- ✅ `config.php` (GÜNCELLENDİ - Output buffering eklendi)
- ✅ `register.php` (GÜNCELLENDİ)
- ✅ `login.php` (GÜNCELLENDİ)
- ✅ `logout.php` (GÜNCELLENDİ)
- ✅ `save_session.php` (GÜNCELLENDİ)
- ✅ `get_sessions.php` (GÜNCELLENDİ)
- ✅ `get_weekly_stats.php` (GÜNCELLENDİ)
- ✅ `get_topic_progress.php` (GÜNCELLENDİ)
- ✅ `get_study_days.php` (GÜNCELLENDİ)
- ✅ `toggle_topic.php` (GÜNCELLENDİ)
- ✅ `.htaccess` (GÜNCELLENDİ - InfinityFree koruması)
- ✅ `test.php` (YENİ - Test için)
- ✅ `database.sql` (Veritabanı şeması)

### 2. Dosya İzinleri
Sunucuda dosya izinlerini ayarlayın:
- Klasörler: `755` veya `750`
- PHP dosyaları: `644`
- `.htaccess`: `644`

### 3. Test
1. **Test dosyasını kontrol edin:**
   - Tarayıcıda açın: `http://calisbenimle.wuaze.com/api/test.php`
   - Sadece JSON görüyorsanız: ✅ Başarılı
   - HTML/JavaScript görüyorsanız: ❌ Hala sorun var

2. **Uygulamayı test edin:**
   - Flutter uygulamasını çalıştırın
   - Kayıt olmayı deneyin
   - Artık JSON yanıt almalısınız

## 🔧 Yapılan Değişiklikler

### InfinityFree JavaScript Enjeksiyonunu Engellemek İçin:

1. **Output Buffering:**
   - Tüm PHP dosyalarında output buffer temizleme
   - `cleanOutputAndSend()` fonksiyonu eklendi
   - Shutdown hook ile ek koruma

2. **.htaccess Güncellemeleri:**
   - Output buffering ayarları
   - Header ayarları
   - InfinityFree koruması

3. **JSON Encoding:**
   - Tüm JSON çıktıları `JSON_UNESCAPED_UNICODE` ile
   - Türkçe karakter desteği

## ⚠️ Önemli Notlar

1. **HTTP/HTTPS:**
   - Şu an API URL'i HTTP kullanıyor
   - HTTPS çalışmıyorsa HTTP kullanın
   - `lib/services/api_service.dart` dosyasında URL kontrol edin

2. **Veritabanı:**
   - Veritabanı bilgileri `config.php` içinde
   - phpMyAdmin'de tabloları oluşturduğunuzdan emin olun

3. **Sorun Giderme:**
   - `test.php` dosyasını çalıştırın
   - Hala HTML dönüyorsa InfinityFree panelini kontrol edin
   - PHP sürümünü kontrol edin (7.4+ önerilir)

## 📝 Kontrol Listesi

- [ ] Tüm PHP dosyaları yüklendi
- [ ] `.htaccess` dosyası yüklendi
- [ ] `test.php` dosyası yüklendi
- [ ] Dosya izinleri ayarlandı
- [ ] `test.php` test edildi (sadece JSON dönüyor mu?)
- [ ] Uygulama test edildi (kayıt çalışıyor mu?)

## 🆘 Sorun Devam Ederse

1. `test.php` dosyasını çalıştırın ve sonucu kontrol edin
2. InfinityFree kontrol panelinde PHP ayarlarını kontrol edin
3. `.htaccess` dosyasının doğru yerde olduğundan emin olun
4. PHP error log'larını kontrol edin

