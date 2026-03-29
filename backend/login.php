<?php
require_once 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Email ve şifre gerekli']);
}

// Kullanıcı kontrolü
$stmt = $pdo->prepare("SELECT id, name, email, password, student_type FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    cleanOutputAndSend(['success' => false, 'message' => 'Email veya şifre hatalı']);
}

// Token oluştur
$token = generateToken($pdo, $user['id']);

// Output buffer'ı tamamen temizle ve JSON gönder
cleanOutputAndSend([
    'success' => true,
    'message' => 'Giriş başarılı',
    'token' => $token,
    'user' => [
        'id' => $user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'student_type' => $user['student_type']
    ],
    'needs_student_type' => empty($user['student_type']) // Öğrenci tipi seçilmemişse true
]);
?>
