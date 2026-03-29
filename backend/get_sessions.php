<?php
require_once 'config.php';

error_log("=== GET_SESSIONS.PHP ===");

$userId = verifyToken($pdo);

error_log("User ID: $userId");

try {
    $stmt = $pdo->prepare("SELECT date, duration_in_seconds FROM study_sessions WHERE user_id = ? ORDER BY date DESC");
    $stmt->execute([$userId]);
    $sessions = $stmt->fetchAll();
    
    error_log("Found " . count($sessions) . " sessions");
    
    $formattedSessions = array_map(function($session) {
        return [
            'date' => $session['date'],
            'durationInSeconds' => intval($session['duration_in_seconds'])
        ];
    }, $sessions);
    
    cleanOutputAndSend([
        'success' => true,
        'sessions' => $formattedSessions
    ]);
} catch (PDOException $e) {
    error_log("SQL Error: " . $e->getMessage());
    cleanOutputAndSend(['success' => false, 'message' => 'Veritabanı hatası: ' . $e->getMessage()]);
}
?>
