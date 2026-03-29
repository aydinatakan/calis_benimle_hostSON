<?php
require_once 'config.php';

error_log("=== GET_WEEKLY_STATS.PHP ===");

$userId = verifyToken($pdo);

error_log("User ID: $userId");

try {
    // Son 7 günün verilerini al
    $stmt = $pdo->prepare("
        SELECT DATE(date) as day, SUM(duration_in_seconds) as total_seconds 
        FROM study_sessions 
        WHERE user_id = ? AND date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        GROUP BY DATE(date)
        ORDER BY DATE(date) ASC
    ");
    $stmt->execute([$userId]);
    $results = $stmt->fetchAll();
    
    error_log("SQL results: " . json_encode($results));
    
    $weeklyStats = [];
    $dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    
    // Son 7 günü oluştur
    for ($i = 6; $i >= 0; $i--) {
        $date = date('Y-m-d', strtotime("-$i days"));
        $dayOfWeek = date('N', strtotime($date)); // 1=Pazartesi, 7=Pazar
        $dayName = $dayNames[$dayOfWeek - 1];
        
        $weeklyStats[$dayName] = 0.0;
        
        error_log("Date: $date, Day: $dayName");
        
        // Bu tarihte veri var mı?
        foreach ($results as $row) {
            if ($row['day'] === $date) {
                $hours = round($row['total_seconds'] / 3600, 2);
                $weeklyStats[$dayName] = $hours;
                error_log("Match found! $date = $dayName: $hours hours");
                break;
            }
        }
    }
    
    error_log("Final weekly stats: " . json_encode($weeklyStats));
    
    cleanOutputAndSend([
        'success' => true,
        'weeklyStats' => $weeklyStats
    ]);
} catch (PDOException $e) {
    error_log("SQL Error: " . $e->getMessage());
    cleanOutputAndSend(['success' => false, 'message' => 'Veritabanı hatası: ' . $e->getMessage()]);
}
?>
