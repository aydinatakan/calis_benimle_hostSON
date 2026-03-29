<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$stmt = $pdo->prepare("
    SELECT exam_type, subject, topic, completed 
    FROM user_topics 
    WHERE user_id = ? AND completed = 1
");
$stmt->execute([$userId]);
$completedTopics = $stmt->fetchAll();

cleanOutputAndSend([
    'success' => true,
    'completedTopics' => $completedTopics
]);
?>
