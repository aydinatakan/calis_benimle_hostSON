<?php
require_once 'config.php';

// Sadece token doğrulama için basit endpoint
$userId = verifyToken($pdo);

cleanOutputAndSend([
    'success' => true,
    'user_id' => $userId
]);
?>

