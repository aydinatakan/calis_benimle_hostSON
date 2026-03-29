import 'package:flutter/material.dart';
import '../services/topic_service.dart';
import '../services/api_service.dart';
import 'add_question_count_screen.dart';

class SubjectsScreenNew extends StatefulWidget {
  const SubjectsScreenNew({super.key});

  @override
  State<SubjectsScreenNew> createState() => _SubjectsScreenNewState();
}

class _SubjectsScreenNewState extends State<SubjectsScreenNew> {
  final TopicService _topicService = TopicService();
  final ApiService _apiService = ApiService();
  
  Map<String, Map<String, List<String>>> _topics = {}; // {examType: {subject: [topics]}}
  Map<String, bool> _completedTopics = {}; // "examType|subject|topic" -> bool
  Map<String, Map<String, int>> _questionCounts = {}; // {examType: {subject: count}}
  String? _studentType;
  bool _isLoading = true;
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Konuları ve tamamlanma durumlarını yükle
      final topicsResponse = await _apiService.getExamTopics();
      if (topicsResponse['success'] == true) {
        _studentType = topicsResponse['student_type'];
        _topics = Map<String, Map<String, List<String>>>.from(
          (topicsResponse['topics'] as Map).map(
            (key, value) => MapEntry(
              key.toString(),
              Map<String, List<String>>.from(
                (value as Map).map(
                  (subKey, subValue) => MapEntry(
                    subKey.toString(),
                    List<String>.from(
                      (subValue as List).map((t) => t['topic'] as String),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tamamlanma durumlarını yükle
        final completedMap = topicsResponse['completed_topics'] as Map? ?? {};
        _completedTopics = Map<String, bool>.from(
          completedMap.map((key, value) => MapEntry(key.toString(), value as bool)),
        );
      }

      // Soru sayılarını yükle
      final countsResponse = await _apiService.getSubjectQuestionCounts();
      if (countsResponse['success'] == true) {
        _questionCounts = Map<String, Map<String, int>>.from(
          (countsResponse['question_counts'] as Map).map(
            (key, value) => MapEntry(
              key.toString(),
              Map<String, int>.from(
                (value as Map).map(
                  (subKey, subValue) => MapEntry(
                    subKey.toString(),
                    subValue as int,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('🔴 [SUBJECTS] Hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTopic(String examType, String subject, String topic) async {
    final topicKey = '$examType|$subject|$topic';
    final currentlyCompleted = _completedTopics[topicKey] ?? false;
    final newState = !currentlyCompleted;

    // Optimistic update
    setState(() {
      _completedTopics[topicKey] = newState;
    });

    // Save to backend
    final success = await _topicService.toggleTopic(
      examType: examType,
      subject: subject,
      topic: topic,
      completed: newState,
    );

    if (!success && mounted) {
      // Revert on failure
      setState(() {
        _completedTopics[topicKey] = currentlyCompleted;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme başarısız')),
      );
    }
  }

  bool _isTopicCompleted(String examType, String subject, String topic) {
    return _completedTopics['$examType|$subject|$topic'] ?? false;
  }

  int _getCompletedCount(String examType, String subject) {
    final topics = _topics[examType]?[subject] ?? [];
    return topics.where((topic) => _isTopicCompleted(examType, subject, topic)).length;
  }

  int _getTotalCount(String examType) {
    int total = 0;
    final subjects = _topics[examType] ?? {};
    for (var topics in subjects.values) {
      total += topics.length;
    }
    return total;
  }

  int _getTotalCompleted(String examType) {
    int total = 0;
    final subjects = _topics[examType] ?? {};
    for (var entry in subjects.entries) {
      total += _getCompletedCount(examType, entry.key);
    }
    return total;
  }

  double _getProgress(String examType) {
    final total = _getTotalCount(examType);
    if (total == 0) return 0;
    return _getTotalCompleted(examType) / total;
  }

  int _getQuestionCount(String examType, String subject) {
    return _questionCounts[examType]?[subject] ?? 0;
  }

  Future<void> _addQuestionCount(String examType, String subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionCountScreen(
          examType: examType,
          subject: subject,
        ),
      ),
    );

    if (result == true) {
      _loadData(); // Yeniden yükle
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_topics.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Konular yüklenemedi',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadData,
                child: const Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            Text(
              'Konu Takibi',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tamamladığınız konuları işaretleyin',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Soru Sayıları Bölümü
            if (_questionCounts.isNotEmpty) ...[
              Text(
                'Çözülen Soru Sayıları',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ..._questionCounts.entries.map((examEntry) {
                final examType = examEntry.key;
                final subjects = examEntry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...subjects.entries.map((subjectEntry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(subjectEntry.key),
                                Text(
                                  '${subjectEntry.value} soru',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],

            // Konular Bölümü
            ..._topics.entries.map((examEntry) {
              final examType = examEntry.key;
              final subjects = examEntry.value;
              final examTypeColor = examType == 'TYT' || examType == 'LGS'
                  ? colorScheme.primary
                  : colorScheme.secondary;

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$examType Konuları',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_getTotalCompleted(examType)} / ${_getTotalCount(examType)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: examTypeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _getProgress(examType),
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(examTypeColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...subjects.entries.map((subjectEntry) {
                        final subject = subjectEntry.key;
                        final topics = subjectEntry.value;
                        final categoryKey = '$examType-${subjectEntry.key}';
                        final isExpanded = _expandedCategories[categoryKey] ?? false;

                        return _CategoryCard(
                          examType: examType,
                          subject: subject,
                          topics: topics,
                          completedTopics: _completedTopics,
                          isExpanded: isExpanded,
                          questionCount: _getQuestionCount(examType, subject),
                          onExpand: () {
                            setState(() {
                              _expandedCategories[categoryKey] = !isExpanded;
                            });
                          },
                          onToggle: (topic) {
                            _toggleTopic(examType, subject, topic);
                          },
                          onAddQuestion: () {
                            _addQuestionCount(examType, subject);
                          },
                          isPrimary: examType == 'TYT' || examType == 'LGS',
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 100), // Bottom nav padding
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String examType;
  final String subject;
  final List<String> topics;
  final Map<String, bool> completedTopics;
  final bool isExpanded;
  final int questionCount;
  final VoidCallback onExpand;
  final Function(String topic) onToggle;
  final VoidCallback onAddQuestion;
  final bool isPrimary;

  const _CategoryCard({
    required this.examType,
    required this.subject,
    required this.topics,
    required this.completedTopics,
    required this.isExpanded,
    required this.questionCount,
    required this.onExpand,
    required this.onToggle,
    required this.onAddQuestion,
    required this.isPrimary,
  });

  bool _isCompleted(String topic) {
    return completedTopics['$examType|$subject|$topic'] ?? false;
  }

  int _getCompletedCount() {
    return topics.where((t) => _isCompleted(t)).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedCount = _getCompletedCount();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        child: Column(
          children: [
            InkWell(
              onTap: onExpand,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (questionCount > 0)
                            Text(
                              '$questionCount soru çözüldü',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$completedCount/${topics.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: onAddQuestion,
                          tooltip: 'Soru Sayısı Ekle',
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: topics.map((topic) {
                    final isCompleted = _isCompleted(topic);
                    return CheckboxListTile(
                      value: isCompleted,
                      onChanged: (_) => onToggle(topic),
                      title: Text(
                        topic,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: isPrimary ? colorScheme.primary : colorScheme.secondary,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

