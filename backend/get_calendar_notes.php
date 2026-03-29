<?php
require_once 'config.php';

$userId = verifyToken($pdo);

// Tüm takvim notlarını getir
$stmt = $pdo->prepare("
    SELECT id, note_date, title, description, reminder_time, is_reminder_sent, created_at
    FROM calendar_notes
    WHERE user_id = ?
    ORDER BY note_date ASC
");
$stmt->execute([$userId]);
$notes = $stmt->fetchAll();

$formattedNotes = [];
foreach ($notes as $note) {
    $formattedNotes[] = [
        'id' => (int)$note['id'],
        'note_date' => $note['note_date'],
        'title' => $note['title'],
        'description' => $note['description'],
        'reminder_time' => $note['reminder_time'],
        'is_reminder_sent' => (bool)$note['is_reminder_sent'],
        'created_at' => $note['created_at']
    ];
}

cleanOutputAndSend([
    'success' => true,
    'notes' => $formattedNotes
]);
?>

