<?php
require_once 'config.php';

// Debug log
error_log("=== SAVE_SESSION.PHP ===");
error_log("Request method: " . $_SERVER['REQUEST_METHOD']);
error_log("Raw input: " . file_get_contents('php://input'));

$userId = verifyToken($pdo);

error_log("User ID from token: " . $userId);

$data = json_decode(file_get_contents('php://input'), true);

error_log("Decoded data: " . json_encode($data));

$date = $data['date'] ?? '';
$durationInSeconds = intval($data['durationInSeconds'] ?? 0);

error_log("Date: $date, Duration: $durationInSeconds");

if (empty($date) || $durationInSeconds <= 0) {
    error_log("Validation failed: empty date or invalid duration");
    cleanOutputAndSend(['success' => false, 'message' => 'Geçersiz veri']);
}

try {
    $stmt = $pdo->prepare("INSERT INTO study_sessions (user_id, date, duration_in_seconds) VALUES (?, ?, ?)");
    $result = $stmt->execute([$userId, $date, $durationInSeconds]);
    
    error_log("SQL Execute result: " . ($result ? 'success' : 'failed'));
    error_log("Last insert ID: " . $pdo->lastInsertId());
    
    cleanOutputAndSend(['success' => true, 'message' => 'Çalışma kaydedildi', 'id' => $pdo->lastInsertId()]);
} catch (PDOException $e) {
    error_log("SQL Error: " . $e->getMessage());
    cleanOutputAndSend(['success' => false, 'message' => 'Veritabanı hatası: ' . $e->getMessage()]);
}
?>
