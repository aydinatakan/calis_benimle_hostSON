<?php
require_once 'config.php';

$headers = getallheaders();
$authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : '';

if (empty($authHeader) || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Token bulunamadı']);
}

$token = $matches[1];

// Token'ı sil
$stmt = $pdo->prepare("DELETE FROM auth_token WHERE token = ?");
$stmt->execute([$token]);

cleanOutputAndSend(['success' => true, 'message' => 'Çıkış başarılı']);
?>
