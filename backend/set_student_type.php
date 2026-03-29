<?php
require_once 'config.php';

// Token doğrulama - verifyToken fonksiyonunu kullan
$userId = verifyToken($pdo);

$data = json_decode(file_get_contents('php://input'), true);

$studentType = $data['student_type'] ?? '';

if (empty($studentType) || !in_array($studentType, ['LGS', 'YKS'])) {
    cleanOutputAndSend(['success' => false, 'message' => 'Geçersiz öğrenci tipi']);
}

// Öğrenci tipini güncelle
$stmt = $pdo->prepare("UPDATE users SET student_type = ? WHERE id = ?");
$stmt->execute([$studentType, $userId]);

cleanOutputAndSend([
    'success' => true,
    'message' => 'Öğrenci tipi kaydedildi',
    'student_type' => $studentType
]);
?>

