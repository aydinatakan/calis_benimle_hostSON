<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$data = json_decode(file_get_contents('php://input'), true);

$examType = $data['exam_type'] ?? '';
$subject = trim($data['subject'] ?? '');
$questionCount = (int)($data['question_count'] ?? 0);

if (empty($examType) || !in_array($examType, ['LGS', 'TYT', 'AYT', 'YDS']) || empty($subject)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Eksik veya geçersiz veri']);
}

// Kayıt var mı kontrol et
$stmt = $pdo->prepare("
    SELECT id, question_count FROM subject_question_counts
    WHERE user_id = ? AND exam_type = ? AND subject = ?
");
$stmt->execute([$userId, $examType, $subject]);
$existing = $stmt->fetch();

// Her ekleme işlemini ayrı kayıt olarak tut (tarih bazlı grafik için)
// Önce toplam sayıyı güncelle
if ($existing) {
    // Güncelle (mevcut sayıya ekle)
    $newCount = $existing['question_count'] + $questionCount;
    $stmt = $pdo->prepare("
        UPDATE subject_question_counts
        SET question_count = ?, updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->execute([$newCount, $existing['id']]);
} else {
    // Yeni kayıt oluştur
    $stmt = $pdo->prepare("
        INSERT INTO subject_question_counts (user_id, exam_type, subject, question_count)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $examType, $subject, $questionCount]);
}

// Aylık istatistik için log kaydı oluştur (her ekleme işlemi için)
// Her ekleme işlemini ayrı kayıt olarak tutmak için log tablosuna kaydet
try {
    $stmt = $pdo->prepare("
        INSERT INTO question_count_logs (user_id, exam_type, subject, question_count)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $examType, $subject, $questionCount]);
} catch (PDOException $e) {
    // Tablo yoksa hata verme (geriye dönük uyumluluk için)
    // Log tablosu yoksa devam et
}

cleanOutputAndSend([
    'success' => true,
    'message' => 'Soru sayısı kaydedildi'
]);
?>

