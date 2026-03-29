<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$data = json_decode(file_get_contents('php://input'), true);

$noteDate = $data['note_date'] ?? '';
$title = trim($data['title'] ?? '');
$description = trim($data['description'] ?? '');

if (empty($noteDate) || empty($title)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Tarih ve başlık gerekli']);
}

// Tarih formatını kontrol et ve düzelt
try {
    $dateObj = new DateTime($noteDate);
    $noteDate = $dateObj->format('Y-m-d');
} catch (Exception $e) {
    cleanOutputAndSend(['success' => false, 'message' => 'Geçersiz tarih formatı']);
}

// Hatırlatma zamanı: Not tarihinden 24 saat önce
$reminderTime = date('Y-m-d H:i:s', strtotime($noteDate . ' -1 day'));

// Kayıt var mı kontrol et (aynı tarih ve kullanıcı için)
$stmt = $pdo->prepare("
    SELECT id FROM calendar_notes
    WHERE user_id = ? AND note_date = ?
");
$stmt->execute([$userId, $noteDate]);
$existing = $stmt->fetch();

if ($existing) {
    // Güncelle
    $stmt = $pdo->prepare("
        UPDATE calendar_notes
        SET title = ?, description = ?, reminder_time = ?, is_reminder_sent = 0, updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->execute([$title, $description, $reminderTime, $existing['id']]);
    $noteId = $existing['id'];
} else {
    // Yeni kayıt oluştur
    $stmt = $pdo->prepare("
        INSERT INTO calendar_notes (user_id, note_date, title, description, reminder_time)
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $noteDate, $title, $description, $reminderTime]);
    $noteId = $pdo->lastInsertId();
}

cleanOutputAndSend([
    'success' => true,
    'message' => 'Takvim notu kaydedildi',
    'note_id' => $noteId
]);
?>

