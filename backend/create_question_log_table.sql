-- Soru sayısı log tablosu (aylık grafik için)
-- Her ekleme işlemini ayrı kayıt olarak tutar
CREATE TABLE IF NOT EXISTS question_count_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exam_type ENUM('LGS', 'TYT', 'AYT', 'YDS') NOT NULL,
    subject VARCHAR(100) NOT NULL,
    question_count INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_question_logs_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

