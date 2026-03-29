<?php
require_once 'config.php';

$userId = verifyToken($pdo);

// Not tarihine 24 saatten az kalan anımsatıcıları getir
// Yani note_date şu andan itibaren 24 saat içinde olan notlar
$stmt = $pdo->prepare("
    SELECT id, note_date, title, description, reminder_time
    FROM calendar_notes
    WHERE user_id = ?
    AND note_date >= DATE(NOW())
    AND note_date <= DATE_ADD(NOW(), INTERVAL 24 HOUR)
    AND (is_reminder_sent = 0 OR is_reminder_sent IS NULL)
    ORDER BY note_date ASC, reminder_time ASC
");
$stmt->execute([$userId]);
$reminders = $stmt->fetchAll();

$formattedReminders = [];
foreach ($reminders as $reminder) {
    $formattedReminders[] = [
        'id' => (int)$reminder['id'],
        'note_date' => $reminder['note_date'],
        'title' => $reminder['title'],
        'description' => $reminder['description'],
        'reminder_time' => $reminder['reminder_time']
    ];
}

cleanOutputAndSend([
    'success' => true,
    'reminders' => $formattedReminders
]);
?>

