<?php
require_once 'config.php';

$userId = verifyToken($pdo);

// Son 12 ayın aylık soru sayılarını getir
// Her ekleme işlemini ayrı kayıt olarak tutmak için log tablosunu kullan
// Eğer log tablosu yoksa, eski yöntemi kullan (geriye dönük uyumluluk)

try {
    // Önce log tablosundan veri çekmeyi dene
    $stmt = $pdo->prepare("
        SELECT 
            DATE_FORMAT(created_at, '%Y-%m') as month,
            SUM(question_count) as total_questions
        FROM question_count_logs
        WHERE user_id = ?
        AND created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
        GROUP BY DATE_FORMAT(created_at, '%Y-%m')
        ORDER BY month ASC
    ");
    $stmt->execute([$userId]);
    $results = $stmt->fetchAll();
    
    $monthlyStats = [];
    foreach ($results as $row) {
        $monthlyStats[] = [
            'month' => $row['month'],
            'total_questions' => (int)$row['total_questions']
        ];
    }
} catch (PDOException $e) {
    // Log tablosu yoksa eski yöntemi kullan
    $stmt = $pdo->prepare("
        SELECT 
            DATE_FORMAT(updated_at, '%Y-%m') as month,
            SUM(question_count) as total_questions
        FROM subject_question_counts
        WHERE user_id = ?
        AND updated_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
        GROUP BY DATE_FORMAT(updated_at, '%Y-%m')
        ORDER BY month ASC
    ");
    $stmt->execute([$userId]);
    $results = $stmt->fetchAll();
    
    $monthlyStats = [];
    foreach ($results as $row) {
        $monthlyStats[] = [
            'month' => $row['month'],
            'total_questions' => (int)$row['total_questions']
        ];
    }
}

cleanOutputAndSend([
    'success' => true,
    'monthly_stats' => $monthlyStats
]);
?>
