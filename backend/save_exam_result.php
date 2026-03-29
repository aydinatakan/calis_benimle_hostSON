<?php
require_once 'config.php';

$userId = verifyToken($pdo);

$data = json_decode(file_get_contents('php://input'), true);

$examName = trim($data['exam_name'] ?? '');
$examDate = $data['exam_date'] ?? '';
$examType = $data['exam_type'] ?? '';
$subjects = $data['subjects'] ?? []; // [{subject: "Türkçe", question_count: 40, correct: 32, wrong: 6}, ...]

if (empty($examName) || empty($examDate) || empty($examType) || !in_array($examType, ['LGS', 'TYT', 'AYT', 'YDS'])) {
    cleanOutputAndSend(['success' => false, 'message' => 'Eksik veya geçersiz veri']);
}

if (empty($subjects) || !is_array($subjects)) {
    cleanOutputAndSend(['success' => false, 'message' => 'Ders bilgileri gerekli']);
}

// Toplamları hesapla
$totalQuestions = 0;
$totalCorrect = 0;
$totalWrong = 0;
$totalNet = 0.0;

foreach ($subjects as $subject) {
    $qCount = (int)($subject['question_count'] ?? 0);
    $correct = (int)($subject['correct'] ?? 0);
    $wrong = (int)($subject['wrong'] ?? 0);
    $net = $correct - ($wrong / 4.0); // Net = Doğru - (Yanlış/4)
    
    $totalQuestions += $qCount;
    $totalCorrect += $correct;
    $totalWrong += $wrong;
    $totalNet += $net;
}

// Deneme sonucunu kaydet
$pdo->beginTransaction();
try {
    $stmt = $pdo->prepare("
        INSERT INTO exam_results 
        (user_id, exam_name, exam_date, exam_type, total_questions, total_correct, total_wrong, total_net)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $userId,
        $examName,
        $examDate,
        $examType,
        $totalQuestions,
        $totalCorrect,
        $totalWrong,
        $totalNet
    ]);
    
    $examResultId = $pdo->lastInsertId();
    
    // Ders bazlı sonuçları kaydet
    $stmt = $pdo->prepare("
        INSERT INTO exam_result_subjects 
        (exam_result_id, subject, question_count, correct_count, wrong_count, net)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    
    foreach ($subjects as $subject) {
        $qCount = (int)($subject['question_count'] ?? 0);
        $correct = (int)($subject['correct'] ?? 0);
        $wrong = (int)($subject['wrong'] ?? 0);
        $net = $correct - ($wrong / 4.0);
        
        $stmt->execute([
            $examResultId,
            $subject['subject'],
            $qCount,
            $correct,
            $wrong,
            $net
        ]);
    }
    
    $pdo->commit();
    
    cleanOutputAndSend([
        'success' => true,
        'message' => 'Deneme sonucu kaydedildi',
        'exam_result_id' => $examResultId
    ]);
} catch (Exception $e) {
    $pdo->rollBack();
    cleanOutputAndSend(['success' => false, 'message' => 'Kayıt hatası: ' . $e->getMessage()]);
}
?>

