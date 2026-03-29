<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$stmt = $pdo->prepare("SELECT DISTINCT DATE(date) as study_day FROM study_sessions WHERE user_id = ?");
$stmt->execute([$userId]);
$results = $stmt->fetchAll();

$studyDays = array_map(function($row) {
    return $row['study_day'];
}, $results);

cleanOutputAndSend([
    'success' => true,
    'studyDays' => $studyDays
]);
?>
