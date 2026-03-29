<?php
require_once 'config.php';

$userId = verifyToken($pdo);

// Kullanıcının öğrenci tipini al
$stmt = $pdo->prepare("SELECT student_type FROM users WHERE id = ?");
$stmt->execute([$userId]);
$user = $stmt->fetch();

if (!$user || empty($user['student_type'])) {
    cleanOutputAndSend([
        'success' => false,
        'message' => 'Öğrenci tipi seçilmemiş'
    ]);
}

$studentType = $user['student_type'];

// Öğrenci tipine göre sınav tiplerini belirle
if ($studentType === 'LGS') {
    $examTypes = ['LGS'];
} else {
    $examTypes = ['TYT', 'AYT', 'YDS'];
}

// Soru sayılarını getir
$placeholders = str_repeat('?,', count($examTypes) - 1) . '?';
$stmt = $pdo->prepare("
    SELECT exam_type, subject, question_count
    FROM subject_question_counts
    WHERE user_id = ? AND exam_type IN ($placeholders)
    ORDER BY exam_type, subject
");
$stmt->execute(array_merge([$userId], $examTypes));
$counts = $stmt->fetchAll();

// Organize et
$organized = [];
foreach ($counts as $count) {
    $examType = $count['exam_type'];
    if (!isset($organized[$examType])) {
        $organized[$examType] = [];
    }
    $organized[$examType][$count['subject']] = (int)$count['question_count'];
}

cleanOutputAndSend([
    'success' => true,
    'question_counts' => $organized
]);
?>

