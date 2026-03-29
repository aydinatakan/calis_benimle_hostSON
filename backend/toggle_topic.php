<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$data = json_decode(file_get_contents('php://input'), true);

$examType = $data['exam_type'] ?? '';
$subject = $data['subject'] ?? '';
$topic = $data['topic'] ?? '';
$completed = $data['completed'] ?? false;

if (empty($examType) || empty($subject) || empty($topic)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Eksik veri']);
}

// Kayıt var mı kontrol et
$stmt = $pdo->prepare("
    SELECT id FROM user_topics 
    WHERE user_id = ? AND exam_type = ? AND subject = ? AND topic = ?
");
$stmt->execute([$userId, $examType, $subject, $topic]);
$existing = $stmt->fetch();

if ($existing) {
    // Güncelle
    $stmt = $pdo->prepare("
        UPDATE user_topics 
        SET completed = ?, completed_at = ? 
        WHERE id = ?
    ");
    $stmt->execute([
        $completed ? 1 : 0,
        $completed ? date('Y-m-d H:i:s') : null,
        $existing['id']
    ]);
} else {
    // Yeni kayıt oluştur
    $stmt = $pdo->prepare("
        INSERT INTO user_topics (user_id, exam_type, subject, topic, completed, completed_at) 
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $userId,
        $examType,
        $subject,
        $topic,
        $completed ? 1 : 0,
        $completed ? date('Y-m-d H:i:s') : null
    ]);
}

cleanOutputAndSend(['success' => true, 'message' => 'Konu güncellendi']);
?>
