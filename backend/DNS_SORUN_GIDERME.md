# DNS Sorun Giderme - Hostinger

## 🔴 Hata: "Failed host lookup: 'proje.cloud'"

Bu hata, domain'in henüz aktif olmadığı veya DNS ayarlarının tamamlanmadığı anlamına gelir.

## ✅ Çözüm Adımları

### 1. Hostinger Kontrol Paneline Giriş Yapın
- Hostinger hesabınıza giriş yapın
- "Websites" veya "Domains" bölümüne gidin

### 2. Domain Ayarlarını Kontrol Edin
- `proje.cloud` domain'inin aktif olduğundan emin olun
- Domain'in hosting hesabınıza bağlı olduğunu kontrol edin

### 3. DNS Ayarlarını Kontrol Edin
Hostinger kontrol panelinde:
1. **Domains** bölümüne gidin
2. `proje.cloud` domain'ini seçin
3. **DNS Settings** veya **Nameservers** bölümünü kontrol edin
4. Nameserver'ların Hostinger'a yönlendirildiğinden emin olun

**Hostinger Nameserver'ları:**
```
ns1.dns-parking.com
ns2.dns-parking.com
```
veya
```
ns1.hostinger.com
ns2.hostinger.com
```

### 4. DNS Yayılımını Bekleyin
- DNS değişiklikleri 24-48 saat sürebilir
- Genellikle 1-2 saat içinde aktif olur
- DNS yayılımını kontrol etmek için: https://www.whatsmydns.net/

### 5. SSL Sertifikasını Kontrol Edin
- Hostinger kontrol panelinde SSL sertifikasının kurulu olduğundan emin olun
- Let's Encrypt SSL ücretsiz kurulabilir

## 🔍 Domain Kontrolü

### Tarayıcıda Test Edin
1. Tarayıcıda açın: `https://proje.cloud`
2. Eğer site açılıyorsa: ✅ Domain aktif
3. Eğer açılmıyorsa: ❌ DNS ayarları tamamlanmamış

### API Test
1. Tarayıcıda açın: `https://proje.cloud/calisbenimle/api/test.php`
2. JSON görüyorsanız: ✅ API çalışıyor
3. Hata görüyorsanız: ❌ Dosya yolu veya DNS sorunu

## ⚠️ Geçici Çözüm (Önerilmez)

Eğer acil test etmeniz gerekiyorsa, Hostinger'ın verdiği IP adresini kullanabilirsiniz:

1. Hostinger kontrol panelinde **Server IP** adresini bulun
2. Geçici olarak `api_service.dart` dosyasında IP kullanın:
   ```dart
   static const String baseUrl = 'http://IP_ADRESI/calisbenimle/api';
   ```
3. **NOT:** Bu geçici bir çözümdür, production'da domain kullanın

## 📝 Kontrol Listesi

- [ ] Hostinger kontrol panelinde domain aktif mi?
- [ ] DNS ayarları doğru mu?
- [ ] Nameserver'lar Hostinger'a yönlendirilmiş mi?
- [ ] SSL sertifikası kurulu mu?
- [ ] Tarayıcıda `https://proje.cloud` açılıyor mu?
- [ ] DNS yayılımı tamamlandı mı? (24-48 saat)

## 🆘 Hala Çalışmıyorsa

1. **Hostinger Destek:** Hostinger müşteri hizmetlerine başvurun
2. **DNS Kontrolü:** https://www.whatsmydns.net/ adresinden DNS yayılımını kontrol edin
3. **Domain Kontrolü:** Domain'in Hostinger'a bağlı olduğundan emin olun

## ✅ DNS Aktif Olduktan Sonra

DNS aktif olduğunda:
1. Uygulamayı yeniden başlatın
2. Kayıt/giriş işlemlerini test edin
3. Her şey çalışmalı! 🎉

