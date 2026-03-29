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
        'message' => 'Öğrenci tipi seçilmemiş',
        'needs_student_type' => true
    ]);
}

$studentType = $user['student_type'];

// Öğrenci tipine göre sınav tiplerini belirle
if ($studentType === 'LGS') {
    $examTypes = ['LGS'];
} else { // YKS
    $examTypes = ['TYT', 'AYT', 'YDS'];
}

// Konuları getir
$placeholders = str_repeat('?,', count($examTypes) - 1) . '?';
$stmt = $pdo->prepare("
    SELECT exam_type, subject, topic, semester, display_order
    FROM exam_topics
    WHERE exam_type IN ($placeholders)
    ORDER BY exam_type, subject, display_order, topic
");
$stmt->execute($examTypes);
$topics = $stmt->fetchAll();

// Konuları organize et
$organized = [];
foreach ($topics as $topic) {
    $examType = $topic['exam_type'];
    $subject = $topic['subject'];
    
    if (!isset($organized[$examType])) {
        $organized[$examType] = [];
    }
    if (!isset($organized[$examType][$subject])) {
        $organized[$examType][$subject] = [];
    }
    
    $organized[$examType][$subject][] = [
        'topic' => $topic['topic'],
        'semester' => $topic['semester']
    ];
}

// Kullanıcının tamamladığı konuları getir
$stmt = $pdo->prepare("
    SELECT exam_type, subject, topic, completed
    FROM user_topics
    WHERE user_id = ? AND exam_type IN ($placeholders)
");
$stmt->execute(array_merge([$userId], $examTypes));
$completedTopics = $stmt->fetchAll();

// Tamamlanma durumunu ekle
$completedMap = [];
foreach ($completedTopics as $ct) {
    $key = $ct['exam_type'] . '|' . $ct['subject'] . '|' . $ct['topic'];
    $completedMap[$key] = (bool)$ct['completed'];
}

cleanOutputAndSend([
    'success' => true,
    'student_type' => $studentType,
    'topics' => $organized,
    'completed_topics' => $completedMap
]);
?>

