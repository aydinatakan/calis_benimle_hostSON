<?php
// Headers - Hostinger'da temiz çalışır
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('X-Content-Type-Options: nosniff');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Hostinger MySQL ayarları
$host = 'localhost';  // Hostinger'da genellikle localhost
$dbname = 'u499931761_calisbenimle';  // Veritabanı adı
$username = 'u499931761_atakan';
$password = 'Atakan987.?';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch(PDOException $e) {
    cleanOutputAndSend(['success' => false, 'message' => 'Veritabanı bağlantı hatası: ' . $e->getMessage()]);
}

// Token doğrulama fonksiyonu
function verifyToken($pdo) {
    // Header'ı farklı yollarla okumayı dene
    $authHeader = '';
    
    // Yöntem 1: getallheaders()
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : 
                     (isset($headers['authorization']) ? $headers['authorization'] : '');
    }
    
    // Yöntem 2: $_SERVER['HTTP_AUTHORIZATION']
    if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    }
    
    // Yöntem 3: Apache'nin redirect ettiği header
    if (empty($authHeader) && isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }
    
    error_log("Authorization header: " . $authHeader);
    
    if (empty($authHeader) || !preg_match('/Bearer\s+(\S+)/', $authHeader, $matches)) {
        error_log("Token extraction failed. Auth header: " . $authHeader);
        cleanOutputAndSend(['success' => false, 'message' => 'Token bulunamadı']);
    }
    
    $token = $matches[1];
    error_log("Extracted token: " . substr($token, 0, 10) . "...");
    
    $stmt = $pdo->prepare("SELECT user_id, expires_at FROM auth_token WHERE token = ? AND expires_at > NOW()");
    $stmt->execute([$token]);
    $result = $stmt->fetch();
    
    if (!$result) {
        error_log("Token not found in database or expired");
        cleanOutputAndSend(['success' => false, 'message' => 'Geçersiz veya süresi dolmuş token']);
    }
    
    error_log("Token valid. User ID: " . $result['user_id']);
    return $result['user_id'];
}

// Token oluşturma fonksiyonu
function generateToken($pdo, $userId) {
    // Eski tokenleri temizle
    $stmt = $pdo->prepare("DELETE FROM auth_token WHERE user_id = ?");
    $stmt->execute([$userId]);
    
    // Yeni token oluştur
    $token = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));
    
    $stmt = $pdo->prepare("INSERT INTO auth_token (user_id, token, expires_at) VALUES (?, ?, ?)");
    $stmt->execute([$userId, $token, $expiresAt]);
    
    return $token;
}

// Hostinger'da temiz JSON gönderme fonksiyonu
function cleanOutputAndSend($data) {
    // JSON encode ve gönder
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}
?>