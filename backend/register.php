<?php
require_once 'config.php';

$data = json_decode(file_get_contents('php://input'), true);

$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($name) || empty($email) || empty($password)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Tüm alanlar zorunludur']);
}

// Email kontrolü
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    cleanOutputAndSend(['success' => false, 'message' => 'Bu email zaten kayıtlı']);
}

// Şifre hash'leme
$passwordHash = password_hash($password, PASSWORD_BCRYPT);

// Kullanıcı oluşturma (student_type NULL olarak başlatılır, sonra seçilecek)
$stmt = $pdo->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
$stmt->execute([$name, $email, $passwordHash]);

$userId = $pdo->lastInsertId();

// Token oluştur
$token = generateToken($pdo, $userId);

// Output buffer'ı tamamen temizle ve JSON gönder
cleanOutputAndSend([
    'success' => true,
    'message' => 'Kayıt başarılı',
    'token' => $token,
    'user' => [
        'id' => $userId,
        'name' => $name,
        'email' => $email,
        'student_type' => null
    ],
    'needs_student_type' => true // İlk kayıtta öğrenci tipi seçimi gerekiyor
]);
?>
