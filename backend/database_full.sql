-- ============================================================
-- CalisBenimle - TAM VERİTABANI (Sıfırdan Kurulum)
-- Hostinger: u499931761_calisbenimle
-- Tarih: 2026-06-15
-- ============================================================
-- phpMyAdmin'de bu dosyayı çalıştırın.
-- Tüm tablolar + tüm sınav konuları dahildir.
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET collation_connection = 'utf8mb4_turkish_ci';


-- ============================================================
-- TABLO 1: USERS (Kullanıcılar)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    student_type ENUM('LGS', 'YKS') DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

-- Eğer users tablosu zaten varsa:
-- ALTER TABLE users ADD COLUMN student_type ENUM('LGS', 'YKS') DEFAULT NULL AFTER password;


-- ============================================================
-- TABLO 2: AUTH_TOKEN
-- ============================================================
CREATE TABLE IF NOT EXISTS auth_token (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_token (token),
    INDEX idx_user_id (user_id),
    CONSTRAINT fk_tokens_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 3: STUDY_SESSIONS (Çalışma Seansları)
-- ============================================================
CREATE TABLE IF NOT EXISTS study_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATETIME NOT NULL,
    duration_in_seconds INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_date (user_id, date),
    CONSTRAINT fk_sessions_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 4: USER_TOPICS (Kullanıcı Konu Takibi)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    subject VARCHAR(100) NOT NULL,
    topic VARCHAR(200) NOT NULL,
    completed BOOLEAN DEFAULT 0,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_exam (user_id, exam_type),
    CONSTRAINT fk_topics_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_user_topic
        UNIQUE (user_id, exam_type, subject, topic)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 5: EXAM_TOPICS (Sınav Konu Listesi - Sabit Veri)
-- ============================================================
CREATE TABLE IF NOT EXISTS exam_topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    subject VARCHAR(100) NOT NULL,
    topic VARCHAR(200) NOT NULL,
    semester TINYINT DEFAULT 0,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_exam_type (exam_type),
    INDEX idx_exam_subject (exam_type, subject),
    UNIQUE KEY unique_exam_topic (exam_type, subject, topic)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 6: EXAM_RESULTS (Deneme Sonuçları)
-- ============================================================
CREATE TABLE IF NOT EXISTS exam_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exam_name VARCHAR(200) NOT NULL,
    exam_date DATE NOT NULL,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    total_questions INT NOT NULL DEFAULT 0,
    total_correct INT NOT NULL DEFAULT 0,
    total_wrong INT NOT NULL DEFAULT 0,
    total_net DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_exam (user_id, exam_type),
    CONSTRAINT fk_exam_results_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 7: EXAM_RESULT_SUBJECTS (Deneme Ders Detayları)
-- ============================================================
CREATE TABLE IF NOT EXISTS exam_result_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_result_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    question_count INT NOT NULL DEFAULT 0,
    correct_count INT NOT NULL DEFAULT 0,
    wrong_count INT NOT NULL DEFAULT 0,
    net DECIMAL(6,2) NOT NULL DEFAULT 0.00,
    INDEX idx_exam_result_id (exam_result_id),
    CONSTRAINT fk_exam_result_subjects_result
        FOREIGN KEY (exam_result_id) REFERENCES exam_results(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 8: CALENDAR_NOTES (Takvim Notları)
-- ============================================================
CREATE TABLE IF NOT EXISTS calendar_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    note_date DATE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT DEFAULT NULL,
    reminder_time DATETIME DEFAULT NULL,
    is_reminder_sent BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_date (user_id, note_date),
    CONSTRAINT fk_calendar_notes_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 9: SUBJECT_QUESTION_COUNTS (Ders Bazlı Toplam Soru)
-- ============================================================
CREATE TABLE IF NOT EXISTS subject_question_counts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    subject VARCHAR(100) NOT NULL,
    question_count INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_exam_subject (user_id, exam_type, subject),
    CONSTRAINT fk_subject_question_counts_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- TABLO 10: QUESTION_COUNT_LOGS (Soru Sayısı Günlük)
-- ============================================================
CREATE TABLE IF NOT EXISTS question_count_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    subject VARCHAR(100) NOT NULL,
    question_count INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_date (user_id, created_at),
    CONSTRAINT fk_question_logs_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;


-- ============================================================
-- ============================================================
--          SINAV KONULARI (exam_topics INSERT)
-- ============================================================
-- ============================================================


-- ************************************************************
--                    LGS KONULARI
-- ************************************************************

-- ============================================================
-- LGS TÜRKÇE - 1. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Türkçe', 'Fiilimsiler (İsim-Fiil, Sıfat-Fiil, Zarf-Fiil)', 1, 1),
('LGS', 'Türkçe', 'Cümlenin Ögeleri', 1, 2),
('LGS', 'Türkçe', 'İsim ve Fiil Cümlesi', 1, 3),
('LGS', 'Türkçe', 'Kurallı ve Devrik Cümle', 1, 4),
('LGS', 'Türkçe', 'Basit Cümle', 1, 5),
('LGS', 'Türkçe', 'Birleşik Cümle', 1, 6),
('LGS', 'Türkçe', 'Sıralı Cümle', 1, 7),
('LGS', 'Türkçe', 'Bağlı Cümle', 1, 8),
('LGS', 'Türkçe', 'Sözcükte Anlam', 1, 9),
('LGS', 'Türkçe', 'Cümlede Anlam İlişkileri', 1, 10),
('LGS', 'Türkçe', 'Cümle Yorumlama', 1, 11),
('LGS', 'Türkçe', 'Metin Türleri (Fıkra, Makale, Deneme, Roman, Destan)', 1, 12),
('LGS', 'Türkçe', 'Haber, Günlük, Anı, Hikâye, Masal, Fabl', 1, 13),
('LGS', 'Türkçe', 'Röportaj, Biyografi, Otobiyografi, Dilekçe, Reklam', 1, 14),
('LGS', 'Türkçe', 'Söz Sanatları (Abartma, Benzetme, Kişileştirme, Konuşturma, Karşıtlık)', 1, 15),
('LGS', 'Türkçe', 'Yazım (İmla) Kuralları', 1, 16),
('LGS', 'Türkçe', 'Noktalama İşaretleri', 1, 17);

-- ============================================================
-- LGS TÜRKÇE - 2. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Türkçe', 'Paragrafın Anlam Yönü', 2, 18),
('LGS', 'Türkçe', 'Paragrafın Yapı Yönü', 2, 19),
('LGS', 'Türkçe', 'Tablo ve Grafik İnceleme', 2, 20),
('LGS', 'Türkçe', 'Görsel Yorumlama', 2, 21),
('LGS', 'Türkçe', 'Sözel Mantık (Akıl Yürütme)', 2, 22),
('LGS', 'Türkçe', 'Cümlede Anlam', 2, 23),
('LGS', 'Türkçe', 'Fiillerde Çatı', 2, 24),
('LGS', 'Türkçe', 'Anlatım Bozuklukları', 2, 25);

-- ============================================================
-- LGS MATEMATİK - 1. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Matematik', 'Çarpanlar ve Katlar', 1, 1),
('LGS', 'Matematik', 'Üslü İfadeler', 1, 2),
('LGS', 'Matematik', 'Kareköklü İfadeler', 1, 3),
('LGS', 'Matematik', 'Veri Analizi', 1, 4),
('LGS', 'Matematik', 'Basit Olayların Olma Olasılığı', 1, 5),
('LGS', 'Matematik', 'Cebirsel İfadeler ve Özdeşlikler', 1, 6);

-- ============================================================
-- LGS MATEMATİK - 2. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Matematik', 'Doğrusal Denklemler', 2, 7),
('LGS', 'Matematik', 'Eşitsizlikler', 2, 8),
('LGS', 'Matematik', 'Üçgenler', 2, 9),
('LGS', 'Matematik', 'Eşlik ve Benzerlik', 2, 10),
('LGS', 'Matematik', 'Geometrik Cisimler', 2, 11),
('LGS', 'Matematik', 'Dönüşüm Geometrisi', 2, 12);

-- ============================================================
-- LGS FEN BİLİMLERİ - 1. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Fen Bilimleri', 'Mevsimler ve İklimler', 1, 1),
('LGS', 'Fen Bilimleri', 'DNA ve Genetik Kod', 1, 2),
('LGS', 'Fen Bilimleri', 'Basınç', 1, 3),
('LGS', 'Fen Bilimleri', 'Madde ve Endüstri', 1, 4),
('LGS', 'Fen Bilimleri', 'Periyodik Sistem', 1, 5),
('LGS', 'Fen Bilimleri', 'Fiziksel ve Kimyasal Değişimler', 1, 6),
('LGS', 'Fen Bilimleri', 'Asitler ve Bazlar', 1, 7);

-- ============================================================
-- LGS FEN BİLİMLERİ - 2. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Fen Bilimleri', 'Basit Makineler', 2, 8),
('LGS', 'Fen Bilimleri', 'Canlılar ve Enerji İlişkileri', 2, 9),
('LGS', 'Fen Bilimleri', 'Enerji Dönüşümleri ve Çevre Bilimi', 2, 10),
('LGS', 'Fen Bilimleri', 'Elektrik Yükleri ve Elektrik Enerjisi', 2, 11);

-- ============================================================
-- LGS DİN KÜLTÜRÜ - 1. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Din Kültürü', 'Kader ve Kaza İnancı', 1, 1),
('LGS', 'Din Kültürü', 'Kader ve Evrendeki Yasalar', 1, 2),
('LGS', 'Din Kültürü', 'İnsanın İradesi ve Kader', 1, 3),
('LGS', 'Din Kültürü', 'Kaderle İlgili Kavramlar', 1, 4),
('LGS', 'Din Kültürü', 'Hz. Musa (a.s.)', 1, 5),
('LGS', 'Din Kültürü', 'Ayet el-Kürsi ve Anlamı', 1, 6),
('LGS', 'Din Kültürü', 'Zekât ve Sadaka İbadeti', 1, 7),
('LGS', 'Din Kültürü', 'Zekât ve Sadakanın Bireysel ve Toplumsal Faydaları', 1, 8),
('LGS', 'Din Kültürü', 'Hz. Şuayb (a.s.)', 1, 9),
('LGS', 'Din Kültürü', 'Maûn Suresi ve Anlamı', 1, 10),
('LGS', 'Din Kültürü', 'Din, Birey ve Toplum', 1, 11),
('LGS', 'Din Kültürü', 'Dinin Temel Gayesi', 1, 12);

-- ============================================================
-- LGS DİN KÜLTÜRÜ - 2. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'Din Kültürü', 'Hz. Yusuf (a.s.)', 2, 13),
('LGS', 'Din Kültürü', 'Asr Suresi ve Anlamı', 2, 14),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in Doğruluğu ve Güvenilir Kişiliği', 2, 15),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in Merhametli ve Affedici Oluşu', 2, 16),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in İstişareye Önem Vermesi', 2, 17),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in Davasındaki Cesaret ve Kararlılığı', 2, 18),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in Hakkı Gözetmedeki Hassasiyeti', 2, 19),
('LGS', 'Din Kültürü', 'Hz. Muhammed''in İnsanlara Değer Vermesi', 2, 20),
('LGS', 'Din Kültürü', 'Kureyş Suresi ve Anlamı', 2, 21),
('LGS', 'Din Kültürü', 'İslam Dininin Temel Kaynakları', 2, 22),
('LGS', 'Din Kültürü', 'Kur''an-ı Kerim''in Ana Konuları', 2, 23),
('LGS', 'Din Kültürü', 'Kur''an-ı Kerim''in Temel Özellikleri', 2, 24),
('LGS', 'Din Kültürü', 'Hz. Nuh (a.s.)', 2, 25);

-- ============================================================
-- LGS İNKILAP TARİHİ - 1. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'İnkılap Tarihi', 'Bir Kahraman Doğuyor', 1, 1),
('LGS', 'İnkılap Tarihi', 'Milli Uyanış: Bağımsızlık Yolunda Atılan Adımlar', 1, 2),
('LGS', 'İnkılap Tarihi', 'Milli Bir Destan: Ya İstiklal Ya Ölüm', 1, 3);

-- ============================================================
-- LGS İNKILAP TARİHİ - 2. Dönem
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'İnkılap Tarihi', 'Çağdaş Türkiye Yolunda Adımlar', 2, 4),
('LGS', 'İnkılap Tarihi', 'Demokratikleşme Çabaları', 2, 5),
('LGS', 'İnkılap Tarihi', 'Atatürkçülük', 2, 6),
('LGS', 'İnkılap Tarihi', 'Atatürk Dönemi Türk Dış Politikası ve Atatürk''ün Ölümü', 2, 7),
('LGS', 'İnkılap Tarihi', 'İkinci Dünya Savaşı ve Sonrası', 2, 8);

-- ============================================================
-- LGS İNGİLİZCE
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('LGS', 'İngilizce', 'Friendship', 1, 1),
('LGS', 'İngilizce', 'Teen Life', 1, 2),
('LGS', 'İngilizce', 'In the Kitchen', 1, 3),
('LGS', 'İngilizce', 'On the Phone', 1, 4),
('LGS', 'İngilizce', 'The Internet', 1, 5),
('LGS', 'İngilizce', 'Adventures', 2, 6),
('LGS', 'İngilizce', 'Tourism', 2, 7),
('LGS', 'İngilizce', 'Chores', 2, 8),
('LGS', 'İngilizce', 'Science', 2, 9),
('LGS', 'İngilizce', 'Natural Forces', 2, 10);


-- ************************************************************
--                    TYT KONULARI
-- ************************************************************

-- ============================================================
-- TYT TÜRKÇE
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Türkçe', 'Sözcükte Anlam', 0, 1),
('TYT', 'Türkçe', 'Söz Yorumu', 0, 2),
('TYT', 'Türkçe', 'Deyim ve Atasözü', 0, 3),
('TYT', 'Türkçe', 'Cümlede Anlam', 0, 4),
('TYT', 'Türkçe', 'Paragraf', 0, 5),
('TYT', 'Türkçe', 'Paragrafta Anlatım Teknikleri', 0, 6),
('TYT', 'Türkçe', 'Paragrafta Düşünceyi Geliştirme Yolları', 0, 7),
('TYT', 'Türkçe', 'Paragrafta Yapı', 0, 8),
('TYT', 'Türkçe', 'Paragrafta Konu-Ana Düşünce', 0, 9),
('TYT', 'Türkçe', 'Paragrafta Yardımcı Düşünce', 0, 10),
('TYT', 'Türkçe', 'Ses Bilgisi', 0, 11),
('TYT', 'Türkçe', 'Yazım Kuralları', 0, 12),
('TYT', 'Türkçe', 'Noktalama İşaretleri', 0, 13),
('TYT', 'Türkçe', 'Sözcükte Yapı / Ekler', 0, 14),
('TYT', 'Türkçe', 'İsimler', 0, 15),
('TYT', 'Türkçe', 'Zamirler', 0, 16),
('TYT', 'Türkçe', 'Sıfatlar', 0, 17),
('TYT', 'Türkçe', 'Zarflar', 0, 18),
('TYT', 'Türkçe', 'Edat – Bağlaç – Ünlem', 0, 19),
('TYT', 'Türkçe', 'Fiiller (Anlam, Kip, Kişi, Yapı)', 0, 20),
('TYT', 'Türkçe', 'Ek Fiil', 0, 21),
('TYT', 'Türkçe', 'Fiilimsi', 0, 22),
('TYT', 'Türkçe', 'Fiilde Çatı', 0, 23),
('TYT', 'Türkçe', 'Sözcük Grupları', 0, 24),
('TYT', 'Türkçe', 'Cümlenin Ögeleri', 0, 25),
('TYT', 'Türkçe', 'Cümle Türleri', 0, 26),
('TYT', 'Türkçe', 'Anlatım Bozukluğu', 0, 27);

-- ============================================================
-- TYT MATEMATİK
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Matematik', 'Temel Kavramlar', 0, 1),
('TYT', 'Matematik', 'Sayı Basamakları', 0, 2),
('TYT', 'Matematik', 'Bölme ve Bölünebilme', 0, 3),
('TYT', 'Matematik', 'EBOB – EKOK', 0, 4),
('TYT', 'Matematik', 'Rasyonel Sayılar', 0, 5),
('TYT', 'Matematik', 'Basit Eşitsizlikler', 0, 6),
('TYT', 'Matematik', 'Mutlak Değer', 0, 7),
('TYT', 'Matematik', 'Üslü Sayılar', 0, 8),
('TYT', 'Matematik', 'Köklü Sayılar', 0, 9),
('TYT', 'Matematik', 'Çarpanlara Ayırma', 0, 10),
('TYT', 'Matematik', 'Oran Orantı', 0, 11),
('TYT', 'Matematik', 'Denklem Çözme', 0, 12),
('TYT', 'Matematik', 'Sayı Problemleri', 0, 13),
('TYT', 'Matematik', 'Kesir Problemleri', 0, 14),
('TYT', 'Matematik', 'Yaş Problemleri', 0, 15),
('TYT', 'Matematik', 'Hareket Hız Problemleri', 0, 16),
('TYT', 'Matematik', 'İşçi Emek Problemleri', 0, 17),
('TYT', 'Matematik', 'Yüzde Problemleri', 0, 18),
('TYT', 'Matematik', 'Kar Zarar Problemleri', 0, 19),
('TYT', 'Matematik', 'Karışım Problemleri', 0, 20),
('TYT', 'Matematik', 'Grafik Problemleri', 0, 21),
('TYT', 'Matematik', 'Rutin Olmayan Problemler', 0, 22),
('TYT', 'Matematik', 'Kümeler – Kartezyen Çarpım', 0, 23),
('TYT', 'Matematik', 'Mantık', 0, 24),
('TYT', 'Matematik', 'Fonksiyonlar', 0, 25),
('TYT', 'Matematik', 'Polinomlar', 0, 26),
('TYT', 'Matematik', '2. Dereceden Denklemler', 0, 27),
('TYT', 'Matematik', 'Permütasyon ve Kombinasyon', 0, 28),
('TYT', 'Matematik', 'Olasılık', 0, 29),
('TYT', 'Matematik', 'Veri – İstatistik', 0, 30);

-- ============================================================
-- TYT GEOMETRİ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Geometri', 'Temel Kavramlar', 0, 1),
('TYT', 'Geometri', 'Doğruda Açılar', 0, 2),
('TYT', 'Geometri', 'Üçgende Açılar', 0, 3),
('TYT', 'Geometri', 'Dik Üçgen', 0, 4),
('TYT', 'Geometri', 'İkizkenar Üçgen', 0, 5),
('TYT', 'Geometri', 'Eşkenar Üçgen', 0, 6),
('TYT', 'Geometri', 'Açıortay', 0, 7),
('TYT', 'Geometri', 'Kenarortay', 0, 8),
('TYT', 'Geometri', 'Eşlik ve Benzerlik', 0, 9),
('TYT', 'Geometri', 'Üçgende Alan', 0, 10),
('TYT', 'Geometri', 'Üçgende Benzerlik', 0, 11),
('TYT', 'Geometri', 'Açı Kenar Bağıntıları', 0, 12),
('TYT', 'Geometri', 'Çokgenler', 0, 13),
('TYT', 'Geometri', 'Dörtgenler', 0, 14),
('TYT', 'Geometri', 'Deltoid', 0, 15),
('TYT', 'Geometri', 'Paralelkenar', 0, 16),
('TYT', 'Geometri', 'Eşkenar Dörtgen', 0, 17),
('TYT', 'Geometri', 'Dikdörtgen', 0, 18),
('TYT', 'Geometri', 'Kare', 0, 19),
('TYT', 'Geometri', 'Yamuk', 0, 20),
('TYT', 'Geometri', 'Çemberde Açı', 0, 21),
('TYT', 'Geometri', 'Çemberde Uzunluk', 0, 22),
('TYT', 'Geometri', 'Dairede Çevre ve Alan', 0, 23),
('TYT', 'Geometri', 'Noktanın Analitiği', 0, 24),
('TYT', 'Geometri', 'Doğrunun Analitiği', 0, 25),
('TYT', 'Geometri', 'Dönüşüm Geometrisi', 0, 26),
('TYT', 'Geometri', 'Prizmalar', 0, 27),
('TYT', 'Geometri', 'Küp', 0, 28),
('TYT', 'Geometri', 'Silindir', 0, 29),
('TYT', 'Geometri', 'Piramit', 0, 30),
('TYT', 'Geometri', 'Koni', 0, 31),
('TYT', 'Geometri', 'Küre', 0, 32),
('TYT', 'Geometri', 'Çemberin Analitiği', 0, 33);

-- ============================================================
-- TYT FİZİK
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Fizik', 'Fizik Bilimine Giriş', 0, 1),
('TYT', 'Fizik', 'Madde ve Özellikleri', 0, 2),
('TYT', 'Fizik', 'Sıvıların Kaldırma Kuvveti', 0, 3),
('TYT', 'Fizik', 'Basınç', 0, 4),
('TYT', 'Fizik', 'Isı, Sıcaklık ve Genleşme', 0, 5),
('TYT', 'Fizik', 'Hareket ve Kuvvet', 0, 6),
('TYT', 'Fizik', 'Dinamik', 0, 7),
('TYT', 'Fizik', 'İş, Güç ve Enerji', 0, 8),
('TYT', 'Fizik', 'Elektrik', 0, 9),
('TYT', 'Fizik', 'Manyetizma', 0, 10),
('TYT', 'Fizik', 'Dalgalar', 0, 11),
('TYT', 'Fizik', 'Optik', 0, 12);

-- ============================================================
-- TYT KİMYA
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Kimya', 'Kimya Bilimi', 0, 1),
('TYT', 'Kimya', 'Atom ve Periyodik Sistem', 0, 2),
('TYT', 'Kimya', 'Kimyasal Türler Arası Etkileşimler', 0, 3),
('TYT', 'Kimya', 'Maddenin Halleri', 0, 4),
('TYT', 'Kimya', 'Doğa ve Kimya', 0, 5),
('TYT', 'Kimya', 'Kimyanın Temel Kanunları', 0, 6),
('TYT', 'Kimya', 'Kimyasal Hesaplamalar', 0, 7),
('TYT', 'Kimya', 'Karışımlar', 0, 8),
('TYT', 'Kimya', 'Asit, Baz ve Tuz', 0, 9),
('TYT', 'Kimya', 'Kimya Her Yerde', 0, 10);

-- ============================================================
-- TYT BİYOLOJİ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Biyoloji', 'Canlıların Ortak Özellikleri', 0, 1),
('TYT', 'Biyoloji', 'Canlıların Temel Bileşenleri', 0, 2),
('TYT', 'Biyoloji', 'Hücre ve Organelleri', 0, 3),
('TYT', 'Biyoloji', 'Hücre Zarından Madde Geçişi', 0, 4),
('TYT', 'Biyoloji', 'Canlıların Sınıflandırılması', 0, 5),
('TYT', 'Biyoloji', 'Mitoz ve Eşeysiz Üreme', 0, 6),
('TYT', 'Biyoloji', 'Mayoz ve Eşeyli Üreme', 0, 7),
('TYT', 'Biyoloji', 'Kalıtım', 0, 8),
('TYT', 'Biyoloji', 'Ekosistem Ekolojisi', 0, 9),
('TYT', 'Biyoloji', 'Güncel Çevre Sorunları', 0, 10);

-- ============================================================
-- TYT TARİH
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Tarih', 'Tarih ve Zaman', 0, 1),
('TYT', 'Tarih', 'İnsanlığın İlk Dönemleri', 0, 2),
('TYT', 'Tarih', 'Orta Çağ''da Dünya', 0, 3),
('TYT', 'Tarih', 'İlk ve Orta Çağlarda Türk Dünyası', 0, 4),
('TYT', 'Tarih', 'İslam Medeniyetinin Doğuşu', 0, 5),
('TYT', 'Tarih', 'Türklerin İslamiyet''i Kabulü ve İlk Türk İslam Devletleri', 0, 6),
('TYT', 'Tarih', 'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi', 0, 7),
('TYT', 'Tarih', 'Beylikten Devlete Osmanlı Siyaseti', 0, 8),
('TYT', 'Tarih', 'Devletleşme Sürecinde Savaşçılar ve Askerler', 0, 9),
('TYT', 'Tarih', 'Beylikten Devlete Osmanlı Medeniyeti', 0, 10),
('TYT', 'Tarih', 'Dünya Gücü Osmanlı', 0, 11),
('TYT', 'Tarih', 'Sultan ve Osmanlı Merkez Teşkilatı', 0, 12),
('TYT', 'Tarih', 'Klasik Çağda Osmanlı Toplum Düzeni', 0, 13),
('TYT', 'Tarih', 'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti', 0, 14),
('TYT', 'Tarih', 'Değişim Çağında Avrupa ve Osmanlı', 0, 15),
('TYT', 'Tarih', 'Uluslararası İlişkilerde Denge Stratejisi (1774-1914)', 0, 16),
('TYT', 'Tarih', 'Devrimler Çağında Değişen Devlet-Toplum İlişkileri', 0, 17),
('TYT', 'Tarih', 'Sermaye ve Emek', 0, 18),
('TYT', 'Tarih', 'XIX. ve XX. Yüzyılda Değişen Gündelik Hayat', 0, 19),
('TYT', 'Tarih', 'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya', 0, 20),
('TYT', 'Tarih', 'Milli Mücadele', 0, 21),
('TYT', 'Tarih', 'Atatürkçülük ve Türk İnkılabı', 0, 22);

-- ============================================================
-- TYT COĞRAFYA
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Coğrafya', 'Doğa ve İnsan', 0, 1),
('TYT', 'Coğrafya', 'Dünya''nın Şekli ve Hareketleri', 0, 2),
('TYT', 'Coğrafya', 'Coğrafi Konum', 0, 3),
('TYT', 'Coğrafya', 'Harita Bilgisi', 0, 4),
('TYT', 'Coğrafya', 'Atmosfer ve Sıcaklık', 0, 5),
('TYT', 'Coğrafya', 'İklimler', 0, 6),
('TYT', 'Coğrafya', 'Basınç ve Rüzgarlar', 0, 7),
('TYT', 'Coğrafya', 'Nem, Yağış ve Buharlaşma', 0, 8),
('TYT', 'Coğrafya', 'İç Kuvvetler / Dış Kuvvetler', 0, 9),
('TYT', 'Coğrafya', 'Su – Toprak ve Bitkiler', 0, 10),
('TYT', 'Coğrafya', 'Nüfus', 0, 11),
('TYT', 'Coğrafya', 'Göç', 0, 12),
('TYT', 'Coğrafya', 'Yerleşme', 0, 13),
('TYT', 'Coğrafya', 'Türkiye''nin Yer Şekilleri', 0, 14),
('TYT', 'Coğrafya', 'Ekonomik Faaliyetler', 0, 15),
('TYT', 'Coğrafya', 'Bölgeler', 0, 16),
('TYT', 'Coğrafya', 'Uluslararası Ulaşım Hatları', 0, 17),
('TYT', 'Coğrafya', 'Çevre ve Toplum', 0, 18),
('TYT', 'Coğrafya', 'Doğal Afetler', 0, 19);

-- ============================================================
-- TYT FELSEFE
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Felsefe', 'Felsefe''nin Konusu', 0, 1),
('TYT', 'Felsefe', 'Bilgi Felsefesi', 0, 2),
('TYT', 'Felsefe', 'Varlık Felsefesi', 0, 3),
('TYT', 'Felsefe', 'Ahlak Felsefesi', 0, 4),
('TYT', 'Felsefe', 'Sanat Felsefesi', 0, 5),
('TYT', 'Felsefe', 'Din Felsefesi', 0, 6),
('TYT', 'Felsefe', 'Siyaset Felsefesi', 0, 7),
('TYT', 'Felsefe', 'Bilim Felsefesi', 0, 8),
('TYT', 'Felsefe', 'İlk Çağ Felsefesi', 0, 9),
('TYT', 'Felsefe', '2. Yüzyıl ve 15. Yüzyıl Felsefeleri', 0, 10),
('TYT', 'Felsefe', '15. Yüzyıl ve 17. Yüzyıl Felsefeleri', 0, 11),
('TYT', 'Felsefe', '18. Yüzyıl ve 19. Yüzyıl Felsefeleri', 0, 12),
('TYT', 'Felsefe', '20. Yüzyıl Felsefesi', 0, 13);

-- ============================================================
-- TYT DİN KÜLTÜRÜ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('TYT', 'Din Kültürü', 'Bilgi ve İnanç', 0, 1),
('TYT', 'Din Kültürü', 'İslam ve İbadet', 0, 2),
('TYT', 'Din Kültürü', 'Ahlak ve Değerler', 0, 3),
('TYT', 'Din Kültürü', 'Allah İnsan İlişkisi', 0, 4),
('TYT', 'Din Kültürü', 'Hz. Muhammed (S.A.V.)', 0, 5),
('TYT', 'Din Kültürü', 'Vahiy ve Akıl', 0, 6),
('TYT', 'Din Kültürü', 'İslam Düşüncesinde Yorumlar, Mezhepler', 0, 7),
('TYT', 'Din Kültürü', 'Din, Kültür ve Medeniyet', 0, 8),
('TYT', 'Din Kültürü', 'İslam ve Bilim, Estetik, Barış', 0, 9),
('TYT', 'Din Kültürü', 'Yaşayan Dinler', 0, 10);


-- ************************************************************
--                    AYT KONULARI
-- ************************************************************

-- ============================================================
-- AYT EDEBİYAT
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Edebiyat', 'Anlam Bilgisi', 0, 1),
('AYT', 'Edebiyat', 'Dil Bilgisi', 0, 2),
('AYT', 'Edebiyat', 'Güzel Sanatlar ve Edebiyat', 0, 3),
('AYT', 'Edebiyat', 'Metinlerin Sınıflandırılması', 0, 4),
('AYT', 'Edebiyat', 'Şiir Bilgisi', 0, 5),
('AYT', 'Edebiyat', 'Edebi Sanatlar', 0, 6),
('AYT', 'Edebiyat', 'Türk Edebiyatı Dönemleri', 0, 7),
('AYT', 'Edebiyat', 'İslamiyet Öncesi Türk Edebiyatı ve Geçiş Dönemi', 0, 8),
('AYT', 'Edebiyat', 'Halk Edebiyatı', 0, 9),
('AYT', 'Edebiyat', 'Divan Edebiyatı', 0, 10),
('AYT', 'Edebiyat', 'Tanzimat Edebiyatı', 0, 11),
('AYT', 'Edebiyat', 'Servet-i Fünun Edebiyatı', 0, 12),
('AYT', 'Edebiyat', 'Fecr-i Ati Edebiyatı', 0, 13),
('AYT', 'Edebiyat', 'Milli Edebiyat', 0, 14),
('AYT', 'Edebiyat', 'Cumhuriyet Dönemi Edebiyatı', 0, 15),
('AYT', 'Edebiyat', 'Edebiyat Akımları', 0, 16),
('AYT', 'Edebiyat', 'Dünya Edebiyatı', 0, 17);

-- ============================================================
-- AYT MATEMATİK
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Matematik', 'Temel Kavramlar', 0, 1),
('AYT', 'Matematik', 'Sayı Basamakları', 0, 2),
('AYT', 'Matematik', 'Bölme ve Bölünebilme', 0, 3),
('AYT', 'Matematik', 'EBOB - EKOK', 0, 4),
('AYT', 'Matematik', 'Rasyonel Sayılar', 0, 5),
('AYT', 'Matematik', 'Basit Eşitsizlikler', 0, 6),
('AYT', 'Matematik', 'Mutlak Değer', 0, 7),
('AYT', 'Matematik', 'Üslü Sayılar', 0, 8),
('AYT', 'Matematik', 'Köklü Sayılar', 0, 9),
('AYT', 'Matematik', 'Çarpanlara Ayırma', 0, 10),
('AYT', 'Matematik', 'Oran Orantı', 0, 11),
('AYT', 'Matematik', 'Denklem Çözme', 0, 12),
('AYT', 'Matematik', 'Problemler', 0, 13),
('AYT', 'Matematik', 'Kümeler', 0, 14),
('AYT', 'Matematik', 'Kartezyen Çarpım', 0, 15),
('AYT', 'Matematik', 'Mantık', 0, 16),
('AYT', 'Matematik', 'Fonksiyonlar', 0, 17),
('AYT', 'Matematik', 'Polinomlar', 0, 18),
('AYT', 'Matematik', '2. Dereceden Denklemler', 0, 19),
('AYT', 'Matematik', 'Permütasyon ve Kombinasyon', 0, 20),
('AYT', 'Matematik', 'Binom ve Olasılık', 0, 21),
('AYT', 'Matematik', 'İstatistik', 0, 22),
('AYT', 'Matematik', 'Karmaşık Sayılar', 0, 23),
('AYT', 'Matematik', '2. Dereceden Eşitsizlikler', 0, 24),
('AYT', 'Matematik', 'Parabol', 0, 25),
('AYT', 'Matematik', 'Trigonometri', 0, 26),
('AYT', 'Matematik', 'Logaritma', 0, 27),
('AYT', 'Matematik', 'Diziler', 0, 28),
('AYT', 'Matematik', 'Limit', 0, 29),
('AYT', 'Matematik', 'Türev', 0, 30),
('AYT', 'Matematik', 'İntegral', 0, 31);

-- ============================================================
-- AYT GEOMETRİ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Geometri', 'Temel Kavramlar', 0, 1),
('AYT', 'Geometri', 'Doğruda Açılar', 0, 2),
('AYT', 'Geometri', 'Üçgende Açılar', 0, 3),
('AYT', 'Geometri', 'Dik Üçgen', 0, 4),
('AYT', 'Geometri', 'İkizkenar Üçgen', 0, 5),
('AYT', 'Geometri', 'Eşkenar Üçgen', 0, 6),
('AYT', 'Geometri', 'Açıortay', 0, 7),
('AYT', 'Geometri', 'Kenarortay', 0, 8),
('AYT', 'Geometri', 'Üçgende Alan', 0, 9),
('AYT', 'Geometri', 'Üçgende Benzerlik', 0, 10),
('AYT', 'Geometri', 'Açı Kenar Bağıntıları', 0, 11),
('AYT', 'Geometri', 'Çokgenler', 0, 12),
('AYT', 'Geometri', 'Dörtgenler', 0, 13),
('AYT', 'Geometri', 'Deltoid', 0, 14),
('AYT', 'Geometri', 'Paralelkenar', 0, 15),
('AYT', 'Geometri', 'Eşkenar Dörtgen', 0, 16),
('AYT', 'Geometri', 'Dikdörtgen', 0, 17),
('AYT', 'Geometri', 'Kare', 0, 18),
('AYT', 'Geometri', 'Yamuk', 0, 19),
('AYT', 'Geometri', 'Çember ve Daire', 0, 20),
('AYT', 'Geometri', 'Noktanın Analitiği', 0, 21),
('AYT', 'Geometri', 'Doğrunun Analitiği', 0, 22),
('AYT', 'Geometri', 'Dönüşüm Geometrisi', 0, 23),
('AYT', 'Geometri', 'Dikdörtgenler Prizması', 0, 24),
('AYT', 'Geometri', 'Küp', 0, 25),
('AYT', 'Geometri', 'Silindir', 0, 26),
('AYT', 'Geometri', 'Piramit', 0, 27),
('AYT', 'Geometri', 'Koni', 0, 28),
('AYT', 'Geometri', 'Küre', 0, 29),
('AYT', 'Geometri', 'Çemberin Analitiği', 0, 30);

-- ============================================================
-- AYT FİZİK
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Fizik', 'Vektörler', 0, 1),
('AYT', 'Fizik', 'Kuvvet, Tork ve Denge', 0, 2),
('AYT', 'Fizik', 'Kütle Merkezi', 0, 3),
('AYT', 'Fizik', 'Basit Makineler', 0, 4),
('AYT', 'Fizik', 'Hareket', 0, 5),
('AYT', 'Fizik', 'Newton''un Hareket Yasaları', 0, 6),
('AYT', 'Fizik', 'İş, Güç ve Enerji II', 0, 7),
('AYT', 'Fizik', 'Atışlar', 0, 8),
('AYT', 'Fizik', 'İtme ve Momentum', 0, 9),
('AYT', 'Fizik', 'Elektrik Alan ve Potansiyel', 0, 10),
('AYT', 'Fizik', 'Paralel Levhalar ve Sığa', 0, 11),
('AYT', 'Fizik', 'Manyetik Alan ve Manyetik Kuvvet', 0, 12),
('AYT', 'Fizik', 'İndüksiyon, Alternatif Akım ve Transformatörler', 0, 13),
('AYT', 'Fizik', 'Çembersel Hareket', 0, 14),
('AYT', 'Fizik', 'Dönme, Yuvarlanma ve Açısal Momentum', 0, 15),
('AYT', 'Fizik', 'Kütle Çekim ve Kepler Yasaları', 0, 16),
('AYT', 'Fizik', 'Basit Harmonik Hareket', 0, 17),
('AYT', 'Fizik', 'Dalga Mekaniği ve Elektromanyetik Dalgalar', 0, 18),
('AYT', 'Fizik', 'Atom Modelleri', 0, 19),
('AYT', 'Fizik', 'Büyük Patlama ve Parçacık Fiziği', 0, 20),
('AYT', 'Fizik', 'Radyoaktivite', 0, 21),
('AYT', 'Fizik', 'Özel Görelilik', 0, 22),
('AYT', 'Fizik', 'Kara Cisim Işıması', 0, 23),
('AYT', 'Fizik', 'Fotoelektrik Olay ve Compton Olayı', 0, 24),
('AYT', 'Fizik', 'Modern Fiziğin Teknolojideki Uygulamaları', 0, 25);

-- ============================================================
-- AYT KİMYA
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Kimya', 'Kimya Bilimi', 0, 1),
('AYT', 'Kimya', 'Atom ve Periyodik Sistem', 0, 2),
('AYT', 'Kimya', 'Kimyasal Türler Arası Etkileşimler', 0, 3),
('AYT', 'Kimya', 'Kimyasal Hesaplamalar', 0, 4),
('AYT', 'Kimya', 'Kimyanın Temel Kanunları', 0, 5),
('AYT', 'Kimya', 'Asit, Baz ve Tuz', 0, 6),
('AYT', 'Kimya', 'Maddenin Halleri', 0, 7),
('AYT', 'Kimya', 'Karışımlar', 0, 8),
('AYT', 'Kimya', 'Doğa ve Kimya', 0, 9),
('AYT', 'Kimya', 'Kimya Her Yerde', 0, 10),
('AYT', 'Kimya', 'Modern Atom Teorisi', 0, 11),
('AYT', 'Kimya', 'Gazlar', 0, 12),
('AYT', 'Kimya', 'Sıvı Çözeltiler', 0, 13),
('AYT', 'Kimya', 'Kimyasal Tepkimelerde Enerji', 0, 14),
('AYT', 'Kimya', 'Kimyasal Tepkimelerde Hız', 0, 15),
('AYT', 'Kimya', 'Kimyasal Tepkimelerde Denge', 0, 16),
('AYT', 'Kimya', 'Asit-Baz Dengesi', 0, 17),
('AYT', 'Kimya', 'Çözünürlük Dengesi', 0, 18),
('AYT', 'Kimya', 'Kimya ve Elektrik', 0, 19),
('AYT', 'Kimya', 'Organik Kimyaya Giriş', 0, 20),
('AYT', 'Kimya', 'Organik Kimya', 0, 21),
('AYT', 'Kimya', 'Enerji Kaynakları ve Bilimsel Gelişmeler', 0, 22);

-- ============================================================
-- AYT BİYOLOJİ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Biyoloji', 'Sinir Sistemi', 0, 1),
('AYT', 'Biyoloji', 'Endokrin Sistem ve Hormonlar', 0, 2),
('AYT', 'Biyoloji', 'Duyu Organları', 0, 3),
('AYT', 'Biyoloji', 'Destek ve Hareket Sistemi', 0, 4),
('AYT', 'Biyoloji', 'Sindirim Sistemi', 0, 5),
('AYT', 'Biyoloji', 'Dolaşım ve Bağışıklık Sistemi', 0, 6),
('AYT', 'Biyoloji', 'Solunum Sistemi', 0, 7),
('AYT', 'Biyoloji', 'Üriner Sistem (Boşaltım Sistemi)', 0, 8),
('AYT', 'Biyoloji', 'Üreme Sistemi ve Embriyonik Gelişim', 0, 9),
('AYT', 'Biyoloji', 'Komünite Ekolojisi', 0, 10),
('AYT', 'Biyoloji', 'Popülasyon Ekolojisi', 0, 11),
('AYT', 'Biyoloji', 'Genden Proteine', 0, 12),
('AYT', 'Biyoloji', 'Nükleik Asitler', 0, 13),
('AYT', 'Biyoloji', 'Genetik Şifre ve Protein Sentezi', 0, 14),
('AYT', 'Biyoloji', 'Canlılık ve Enerji', 0, 15),
('AYT', 'Biyoloji', 'Fotosentez', 0, 16),
('AYT', 'Biyoloji', 'Kemosentez', 0, 17),
('AYT', 'Biyoloji', 'Hücresel Solunum', 0, 18),
('AYT', 'Biyoloji', 'Bitki Biyolojisi', 0, 19),
('AYT', 'Biyoloji', 'Canlılar ve Çevre', 0, 20);

-- ============================================================
-- AYT TARİH
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Tarih', 'Tarih ve Zaman', 0, 1),
('AYT', 'Tarih', 'İnsanlığın İlk Dönemleri', 0, 2),
('AYT', 'Tarih', 'Orta Çağ''da Dünya', 0, 3),
('AYT', 'Tarih', 'İlk ve Orta Çağlarda Türk Dünyası', 0, 4),
('AYT', 'Tarih', 'İslam Medeniyetinin Doğuşu', 0, 5),
('AYT', 'Tarih', 'Türklerin İslamiyet''i Kabulü ve İlk Türk İslam Devletleri', 0, 6),
('AYT', 'Tarih', 'Yerleşme ve Devletleşme Sürecinde Selçuklu Türkiyesi', 0, 7),
('AYT', 'Tarih', 'Beylikten Devlete Osmanlı Siyaseti', 0, 8),
('AYT', 'Tarih', 'Devletleşme Sürecinde Savaşçılar ve Askerler', 0, 9),
('AYT', 'Tarih', 'Beylikten Devlete Osmanlı Medeniyeti', 0, 10),
('AYT', 'Tarih', 'Dünya Gücü Osmanlı', 0, 11),
('AYT', 'Tarih', 'Sultan ve Osmanlı Merkez Teşkilatı', 0, 12),
('AYT', 'Tarih', 'Klasik Çağda Osmanlı Toplum Düzeni', 0, 13),
('AYT', 'Tarih', 'Değişen Dünya Dengeleri Karşısında Osmanlı Siyaseti', 0, 14),
('AYT', 'Tarih', 'Değişim Çağında Avrupa ve Osmanlı', 0, 15),
('AYT', 'Tarih', 'Uluslararası İlişkilerde Denge Stratejisi (1774-1914)', 0, 16),
('AYT', 'Tarih', 'Devrimler Çağında Değişen Devlet-Toplum İlişkileri', 0, 17),
('AYT', 'Tarih', 'Sermaye ve Emek', 0, 18),
('AYT', 'Tarih', 'XIX. ve XX. Yüzyılda Değişen Gündelik Hayat', 0, 19),
('AYT', 'Tarih', 'XX. Yüzyıl Başlarında Osmanlı Devleti ve Dünya', 0, 20),
('AYT', 'Tarih', 'Milli Mücadele', 0, 21),
('AYT', 'Tarih', 'Atatürkçülük ve Türk İnkılabı', 0, 22),
('AYT', 'Tarih', 'İki Savaş Arasındaki Dönemde Türkiye ve Dünya', 0, 23),
('AYT', 'Tarih', 'II. Dünya Savaşı Sürecinde Türkiye ve Dünya', 0, 24),
('AYT', 'Tarih', 'II. Dünya Savaşı Sonrasında Türkiye ve Dünya', 0, 25),
('AYT', 'Tarih', 'Toplumsal Devrim Çağında Dünya ve Türkiye', 0, 26),
('AYT', 'Tarih', 'XXI. Yüzyılın Eşiğinde Türkiye ve Dünya', 0, 27);

-- ============================================================
-- AYT COĞRAFYA
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Coğrafya', 'Ekosistem', 0, 1),
('AYT', 'Coğrafya', 'Biyoçeşitlilik', 0, 2),
('AYT', 'Coğrafya', 'Biyomlar', 0, 3),
('AYT', 'Coğrafya', 'Enerji Akışı ve Madde Döngüsü', 0, 4),
('AYT', 'Coğrafya', 'Ekstrem Doğa Olayları', 0, 5),
('AYT', 'Coğrafya', 'Küresel İklim Değişimi', 0, 6),
('AYT', 'Coğrafya', 'Nüfus Politikaları', 0, 7),
('AYT', 'Coğrafya', 'Türkiye''de Nüfus ve Yerleşme', 0, 8),
('AYT', 'Coğrafya', 'Ekonomik Faaliyetler ve Doğal Kaynaklar', 0, 9),
('AYT', 'Coğrafya', 'Göç ve Şehirleşme', 0, 10),
('AYT', 'Coğrafya', 'Türkiye''nin Ekonomi Politikaları', 0, 11),
('AYT', 'Coğrafya', 'Türkiye''de Tarım', 0, 12),
('AYT', 'Coğrafya', 'Türkiye''de Hayvancılık', 0, 13),
('AYT', 'Coğrafya', 'Türkiye''de Madenler ve Enerji Kaynakları', 0, 14),
('AYT', 'Coğrafya', 'Türkiye''de Sanayi', 0, 15),
('AYT', 'Coğrafya', 'Türkiye''de Ulaşım', 0, 16),
('AYT', 'Coğrafya', 'Türkiye''de Ticaret ve Turizm', 0, 17),
('AYT', 'Coğrafya', 'Geçmişten Geleceğe Şehir ve Ekonomi', 0, 18),
('AYT', 'Coğrafya', 'Türkiye''nin İşlevsel Bölgeleri ve Kalkınma Projeleri', 0, 19),
('AYT', 'Coğrafya', 'Hizmet Sektörünün Ekonomideki Yeri', 0, 20),
('AYT', 'Coğrafya', 'Küresel Ticaret', 0, 21),
('AYT', 'Coğrafya', 'İlk Uygarlıklar', 0, 22),
('AYT', 'Coğrafya', 'Kültür Bölgeleri ve Türk Kültürü', 0, 23),
('AYT', 'Coğrafya', 'Sanayileşme Süreci: Almanya', 0, 24),
('AYT', 'Coğrafya', 'Tarım ve Ekonomi İlişkisi: Fransa – Somali', 0, 25),
('AYT', 'Coğrafya', 'Ülkeler Arası Etkileşim', 0, 26),
('AYT', 'Coğrafya', 'Jeopolitik Konum', 0, 27),
('AYT', 'Coğrafya', 'Çatışma Bölgeleri', 0, 28),
('AYT', 'Coğrafya', 'Küresel ve Bölgesel Örgütler', 0, 29),
('AYT', 'Coğrafya', 'Çevre Sorunları ve Türleri', 0, 30),
('AYT', 'Coğrafya', 'Madenler ve Enerji Kaynaklarının Çevreye Etkisi', 0, 31),
('AYT', 'Coğrafya', 'Doğal Kaynakların Sürdürülebilir Kullanımı', 0, 32),
('AYT', 'Coğrafya', 'Ekolojik Ayak İzi', 0, 33),
('AYT', 'Coğrafya', 'Doğal Çevrenin Sınırlılığı', 0, 34),
('AYT', 'Coğrafya', 'Çevre Politikaları ve Örgütleri', 0, 35),
('AYT', 'Coğrafya', 'Çevre Anlaşmaları', 0, 36),
('AYT', 'Coğrafya', 'Doğal Afetler', 0, 37);

-- ============================================================
-- AYT FELSEFE (Mantık, Psikoloji, Sosyoloji dahil)
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Felsefe', 'Felsefe''nin Konusu', 0, 1),
('AYT', 'Felsefe', 'Bilgi Felsefesi', 0, 2),
('AYT', 'Felsefe', 'Varlık Felsefesi', 0, 3),
('AYT', 'Felsefe', 'Ahlak Felsefesi', 0, 4),
('AYT', 'Felsefe', 'Sanat Felsefesi', 0, 5),
('AYT', 'Felsefe', 'Din Felsefesi', 0, 6),
('AYT', 'Felsefe', 'Siyaset Felsefesi', 0, 7),
('AYT', 'Felsefe', 'Bilim Felsefesi', 0, 8),
('AYT', 'Felsefe', 'İlk Çağ Felsefesi', 0, 9),
('AYT', 'Felsefe', 'MÖ 6. Yüzyıl – MS 2. Yüzyıl Felsefesi', 0, 10),
('AYT', 'Felsefe', 'MS 2. Yüzyıl – MS 15. Yüzyıl Felsefesi', 0, 11),
('AYT', 'Felsefe', '15. Yüzyıl – 17. Yüzyıl Felsefesi', 0, 12),
('AYT', 'Felsefe', '18. Yüzyıl – 19. Yüzyıl Felsefesi', 0, 13),
('AYT', 'Felsefe', '20. Yüzyıl Felsefesi', 0, 14),
('AYT', 'Felsefe', 'Mantığa Giriş', 0, 15),
('AYT', 'Felsefe', 'Klasik Mantık', 0, 16),
('AYT', 'Felsefe', 'Mantık ve Dil', 0, 17),
('AYT', 'Felsefe', 'Sembolik Mantık', 0, 18),
('AYT', 'Felsefe', 'Psikoloji Bilimini Tanıyalım', 0, 19),
('AYT', 'Felsefe', 'Psikolojinin Temel Süreçleri', 0, 20),
('AYT', 'Felsefe', 'Öğrenme, Bellek, Düşünme', 0, 21),
('AYT', 'Felsefe', 'Ruh Sağlığının Temelleri', 0, 22),
('AYT', 'Felsefe', 'Sosyolojiye Giriş', 0, 23),
('AYT', 'Felsefe', 'Birey ve Toplum', 0, 24),
('AYT', 'Felsefe', 'Toplumsal Yapı', 0, 25),
('AYT', 'Felsefe', 'Toplumsal Değişme ve Gelişme', 0, 26),
('AYT', 'Felsefe', 'Toplum ve Kültür', 0, 27),
('AYT', 'Felsefe', 'Toplumsal Kurumlar', 0, 28);

-- ============================================================
-- AYT DİN KÜLTÜRÜ
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('AYT', 'Din Kültürü', 'Dünya ve Ahiret', 0, 1),
('AYT', 'Din Kültürü', 'Kur''an''a Göre Hz. Muhammed', 0, 2),
('AYT', 'Din Kültürü', 'Kur''an''da Bazı Kavramlar', 0, 3),
('AYT', 'Din Kültürü', 'İnançla İlgili Meseleler', 0, 4),
('AYT', 'Din Kültürü', 'Yahudilik ve Hristiyanlık', 0, 5),
('AYT', 'Din Kültürü', 'İslam ve Bilim', 0, 6),
('AYT', 'Din Kültürü', 'Anadolu''da İslam', 0, 7),
('AYT', 'Din Kültürü', 'İslam Düşüncesinde Tasavvufi Yorumlar', 0, 8),
('AYT', 'Din Kültürü', 'Güncel Dini Meseleler', 0, 9),
('AYT', 'Din Kültürü', 'Hint ve Çin Dinleri', 0, 10);


-- ************************************************************
--                    YDS KONULARI
-- ************************************************************

-- ============================================================
-- YDS İNGİLİZCE
-- ============================================================
INSERT INTO exam_topics (exam_type, subject, topic, semester, display_order) VALUES
('YDS', 'İngilizce', 'Kelime – Phrasal Verb Soruları', 0, 1),
('YDS', 'İngilizce', 'Tense – Preposition – Dilbilgisi Soruları', 0, 2),
('YDS', 'İngilizce', 'Cloze Test Soruları', 0, 3),
('YDS', 'İngilizce', 'Cümle Tamamlama Soruları', 0, 4),
('YDS', 'İngilizce', 'Çeviri Soruları', 0, 5),
('YDS', 'İngilizce', 'Paragraf Soruları', 0, 6),
('YDS', 'İngilizce', 'Diyalog Tamamlama Soruları', 0, 7),
('YDS', 'İngilizce', 'Yakın Anlamlı Cümle Soruları', 0, 8),
('YDS', 'İngilizce', 'Paragraf Tamamlama Soruları', 0, 9),
('YDS', 'İngilizce', 'Anlatım Bütünlüğünü Bozan Cümle Soruları', 0, 10);


-- ============================================================
-- BİTTİ! Toplam 10 tablo + tüm sınav konuları eklendi.
-- ============================================================
