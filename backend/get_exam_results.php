<?php
require_once 'config.php';

$userId = verifyToken($pdo);

// Tüm deneme sonuçlarını getir
$stmt = $pdo->prepare("
    SELECT id, exam_name, exam_date, exam_type, total_questions, total_correct, total_wrong, total_net, created_at
    FROM exam_results
    WHERE user_id = ?
    ORDER BY exam_date DESC, created_at DESC
");
$stmt->execute([$userId]);
$results = $stmt->fetchAll();

// Her deneme sonucu için ders detaylarını getir
$examResultIds = array_column($results, 'id');
$subjectsData = [];

if (!empty($examResultIds)) {
    $placeholders = str_repeat('?,', count($examResultIds) - 1) . '?';
    $stmt = $pdo->prepare("
        SELECT exam_result_id, subject, question_count, correct_count, wrong_count, net
        FROM exam_result_subjects
        WHERE exam_result_id IN ($placeholders)
        ORDER BY exam_result_id, subject
    ");
    $stmt->execute($examResultIds);
    $subjects = $stmt->fetchAll();
    
    foreach ($subjects as $subject) {
        $examResultId = $subject['exam_result_id'];
        if (!isset($subjectsData[$examResultId])) {
            $subjectsData[$examResultId] = [];
        }
        $subjectsData[$examResultId][] = [
            'subject' => $subject['subject'],
            'question_count' => (int)$subject['question_count'],
            'correct' => (int)$subject['correct_count'],
            'wrong' => (int)$subject['wrong_count'],
            'net' => (float)$subject['net']
        ];
    }
}

// Sonuçları birleştir
$finalResults = [];
foreach ($results as $result) {
    $finalResults[] = [
        'id' => (int)$result['id'],
        'exam_name' => $result['exam_name'],
        'exam_date' => $result['exam_date'],
        'exam_type' => $result['exam_type'],
        'total_questions' => (int)$result['total_questions'],
        'total_correct' => (int)$result['total_correct'],
        'total_wrong' => (int)$result['total_wrong'],
        'total_net' => (float)$result['total_net'],
        'created_at' => $result['created_at'],
        'subjects' => $subjectsData[$result['id']] ?? []
    ];
}

cleanOutputAndSend([
    'success' => true,
    'results' => $finalResults
]);
?>

