import 'package:flutter/material.dart';
import '../services/topic_service.dart';
import 'subjects_screen_new.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  // Yeni ekranı kullan
  @override
  Widget build(BuildContext context) {
    return const SubjectsScreenNew();
  }
}

class _SubjectsScreenStateOld extends State<SubjectsScreen> {
  final TopicService _topicService = TopicService();
  Set<String> _completedTopics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedTopics();
  }

  Future<void> _loadCompletedTopics() async {
    final topics = await _topicService.getCompletedTopics();
    setState(() {
      _completedTopics = topics;
      _isLoading = false;
    });
  }

  Future<void> _toggleTopic(String examType, String subject, String topic, bool currentlyCompleted) async {
    final topicKey = '$examType|$subject|$topic';
    final newState = !currentlyCompleted;
    
    // Optimistic update
    setState(() {
      if (newState) {
        _completedTopics.add(topicKey);
      } else {
        _completedTopics.remove(topicKey);
      }
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
        if (newState) {
          _completedTopics.remove(topicKey);
        } else {
          _completedTopics.add(topicKey);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme başarısız')),
      );
    }
  }

  bool _isTopicCompleted(String examType, String subject, String topic) {
    return _completedTopics.contains('$examType|$subject|$topic');
  }
  final Map<String, List<SubjectTopic>> tytSubjects = {
    'TÜRKÇE': [
      SubjectTopic('Sözcükte Anlam'),
      SubjectTopic('Cümlede Anlam'),
      SubjectTopic('Paragraf'),
      SubjectTopic('Ses Bilgisi'),
      SubjectTopic('Yazım Kuralları'),
      SubjectTopic('Noktalama İşaretleri'),
      SubjectTopic('Fiilimsiler'),
      SubjectTopic('Cümle Türleri'),
      SubjectTopic('Anlatım Bozuklukları'),
    ],
    'MATEMATİK': [
      SubjectTopic('Temel Kavramlar'),
      SubjectTopic('Sayı Basamakları'),
      SubjectTopic('Bölme ve Bölünebilme'),
      SubjectTopic('EBOB - EKOK'),
      SubjectTopic('Rasyonel Sayılar'),
      SubjectTopic('Basit Eşitsizlikler'),
      SubjectTopic('Mutlak Değer'),
      SubjectTopic('Üslü Sayılar'),
      SubjectTopic('Köklü Sayılar'),
      SubjectTopic('Oran Orantı'),
      SubjectTopic('Problemler'),
      SubjectTopic('Fonksiyonlar'),
      SubjectTopic('Permütasyon'),
      SubjectTopic('Kombinasyon'),
      SubjectTopic('Olasılık'),
      SubjectTopic('Doğru ve Açı'),
      SubjectTopic('Üçgenler'),
      SubjectTopic('Çokgenler'),
      SubjectTopic('Dörtgenler'),
      SubjectTopic('Çember ve Daire'),
      SubjectTopic('Katı Cisimler'),
    ],
    'FİZİK': [
      SubjectTopic('Fizik Bilimine Giriş'),
      SubjectTopic('Madde ve Özellikleri'),
      SubjectTopic('Hareket ve Kuvvet'),
      SubjectTopic('Enerji'),
      SubjectTopic('Isı ve Sıcaklık'),
      SubjectTopic('Elektrik'),
      SubjectTopic('Optik'),
    ],
    'KİMYA': [
      SubjectTopic('Kimya Bilimi'),
      SubjectTopic('Atom ve Yapısı'),
      SubjectTopic('Periyodik Sistem'),
      SubjectTopic('Kimyasal Türler'),
      SubjectTopic('Kimyasal Tepkimeler'),
      SubjectTopic('Asit - Baz - Tuz'),
      SubjectTopic('Karışımlar'),
    ],
    'BİYOLOJİ': [
      SubjectTopic('Canlıların Ortak Özellikleri'),
      SubjectTopic('Hücre'),
      SubjectTopic('Canlılar Dünyası'),
      SubjectTopic('Hücre Bölünmeleri'),
      SubjectTopic('Kalıtım'),
      SubjectTopic('Ekosistem'),
    ],
    'TARİH': [
      SubjectTopic('Tarih Bilimine Giriş'),
      SubjectTopic('İlk Çağ Uygarlıkları'),
      SubjectTopic('İslam Tarihi'),
      SubjectTopic('Osmanlı Tarihi'),
      SubjectTopic('Atatürk İlkeleri'),
    ],
    'COĞRAFYA': [
      SubjectTopic('Doğa ve İnsan'),
      SubjectTopic('Harita Bilgisi'),
      SubjectTopic('İklim Bilgisi'),
      SubjectTopic('Türkiye Coğrafyası'),
    ],
    'FELSEFE': [
      SubjectTopic('Felsefenin Konusu'),
      SubjectTopic('Bilgi Felsefesi'),
      SubjectTopic('Ahlak Felsefesi'),
    ],
    'DİN KÜLTÜRÜ': [
      SubjectTopic('İslam ve İbadet'),
      SubjectTopic('Ahlak'),
      SubjectTopic('Hz. Muhammed'),
    ],
  };

  final Map<String, List<SubjectTopic>> aytSubjects = {
    'MATEMATİK': [
      SubjectTopic('Fonksiyonlar'),
      SubjectTopic('Polinomlar'),
      SubjectTopic('İkinci Dereceden Denklemler'),
      SubjectTopic('Permütasyon'),
      SubjectTopic('Kombinasyon'),
      SubjectTopic('Olasılık'),
      SubjectTopic('Limit'),
      SubjectTopic('Türev'),
      SubjectTopic('İntegral'),
      SubjectTopic('Trigonometri'),
      SubjectTopic('Analitik Geometri'),
      SubjectTopic('Çember ve Daire'),
      SubjectTopic('Katı Cisimler'),
    ],
    'FİZİK': [
      SubjectTopic('Vektörler'),
      SubjectTopic('Newton Yasaları'),
      SubjectTopic('Elektrik Alan'),
      SubjectTopic('Manyetizma'),
      SubjectTopic('Dalgalar'),
      SubjectTopic('Modern Fizik'),
    ],
    'KİMYA': [
      SubjectTopic('Kimyasal Hesaplamalar'),
      SubjectTopic('Gazlar'),
      SubjectTopic('Tepkime Hızı'),
      SubjectTopic('Kimyasal Denge'),
      SubjectTopic('Elektrokimya'),
      SubjectTopic('Organik Kimya'),
    ],
    'BİYOLOJİ': [
      SubjectTopic('Sinir Sistemi'),
      SubjectTopic('Endokrin Sistem'),
      SubjectTopic('Fotosentez'),
      SubjectTopic('Solunum'),
      SubjectTopic('Genetik'),
      SubjectTopic('Evrim'),
    ],
    'EDEBİYAT': [
      SubjectTopic('Anlam Bilgisi'),
      SubjectTopic('Şiir Bilgisi'),
      SubjectTopic('Roman'),
      SubjectTopic('Cumhuriyet Dönemi'),
    ],
    'TARİH': [
      SubjectTopic('Osmanlı Kültür ve Medeniyeti'),
      SubjectTopic('İnkılap Tarihi'),
      SubjectTopic('Çağdaş Türk ve Dünya Tarihi'),
    ],
    'COĞRAFYA': [
      SubjectTopic('Türkiye Ekonomisi'),
      SubjectTopic('Beşeri Coğrafya'),
      SubjectTopic('Küresel Ortam'),
    ],
    'FELSEFE': [
      SubjectTopic('Psikoloji'),
      SubjectTopic('Sosyoloji'),
      SubjectTopic('Mantık'),
    ],
  };

  final Map<String, List<SubjectTopic>> ydtSubjects = {
    'İNGİLİZCE': [
      SubjectTopic('Kelime Bilgisi'),
      SubjectTopic('Dilbilgisi'),
      SubjectTopic('Cloze Test'),
      SubjectTopic('Paragraf'),
      SubjectTopic('Anlam Bütünlüğü'),
      SubjectTopic('Çeviri'),
    ],
  };

  final Map<String, bool> expandedCategories = {};

  int getTotalCompleted(Map<String, List<SubjectTopic>> subjects, String examType) {
    int count = 0;
    for (var entry in subjects.entries) {
      for (var topic in entry.value) {
        if (_isTopicCompleted(examType, entry.key, topic.name)) {
          count++;
        }
      }
    }
    return count;
  }

  int getTotalTopics(Map<String, List<SubjectTopic>> subjects) {
    int count = 0;
    for (var topics in subjects.values) {
      count += topics.length;
    }
    return count;
  }

  double getProgress(Map<String, List<SubjectTopic>> subjects, String examType) {
    final total = getTotalTopics(subjects);
    if (total == 0) return 0;
    return getTotalCompleted(subjects, examType) / total;
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

            // TYT Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TYT Konuları',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${getTotalCompleted(tytSubjects, 'TYT')} / ${getTotalTopics(tytSubjects)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: getProgress(tytSubjects, 'TYT'),
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...tytSubjects.entries.map((entry) => _CategoryCard(
                      examType: 'TYT',
                      name: entry.key,
                      topics: entry.value,
                      completedTopics: _completedTopics,
                      isExpanded: expandedCategories[entry.key] ?? false,
                      onExpand: () {
                        setState(() {
                          expandedCategories[entry.key] = !(expandedCategories[entry.key] ?? false);
                        });
                      },
                      onToggle: (topicName, isCompleted) {
                        _toggleTopic('TYT', entry.key, topicName, isCompleted);
                      },
                      isPrimary: true,
                    )).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AYT Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AYT Konuları',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${getTotalCompleted(aytSubjects, 'AYT')} / ${getTotalTopics(aytSubjects)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: getProgress(aytSubjects, 'AYT'),
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...aytSubjects.entries.map((entry) => _CategoryCard(
                      examType: 'AYT',
                      name: entry.key,
                      topics: entry.value,
                      completedTopics: _completedTopics,
                      isExpanded: expandedCategories['AYT-${entry.key}'] ?? false,
                      onExpand: () {
                        setState(() {
                          expandedCategories['AYT-${entry.key}'] = !(expandedCategories['AYT-${entry.key}'] ?? false);
                        });
                      },
                      onToggle: (topicName, isCompleted) {
                        _toggleTopic('AYT', entry.key, topicName, isCompleted);
                      },
                      isPrimary: false,
                    )).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // YDT Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YDT Konuları',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${getTotalCompleted(ydtSubjects, 'YDT')} / ${getTotalTopics(ydtSubjects)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: getProgress(ydtSubjects, 'YDT'),
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...ydtSubjects.entries.map((entry) => _CategoryCard(
                      examType: 'YDT',
                      name: entry.key,
                      topics: entry.value,
                      completedTopics: _completedTopics,
                      isExpanded: expandedCategories['YDT-${entry.key}'] ?? false,
                      onExpand: () {
                        setState(() {
                          expandedCategories['YDT-${entry.key}'] = !(expandedCategories['YDT-${entry.key}'] ?? false);
                        });
                      },
                      onToggle: (topicName, isCompleted) {
                        _toggleTopic('YDT', entry.key, topicName, isCompleted);
                      },
                      isPrimary: false,
                    )).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom nav padding
          ],
        ),
      ),
    );
  }
}

class SubjectTopic {
  String name;

  SubjectTopic(this.name);
}

class _CategoryCard extends StatelessWidget {
  final String examType;
  final String name;
  final List<SubjectTopic> topics;
  final Set<String> completedTopics;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(String topicName, bool isCompleted) onToggle;
  final bool isPrimary;

  const _CategoryCard({
    required this.examType,
    required this.name,
    required this.topics,
    required this.completedTopics,
    required this.isExpanded,
    required this.onExpand,
    required this.onToggle,
    required this.isPrimary,
  });

  bool _isCompleted(String topicName) {
    return completedTopics.contains('$examType|$name|$topicName');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedCount = topics.where((t) => _isCompleted(t.name)).length;

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
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
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
                    final isCompleted = _isCompleted(topic.name);
                    return CheckboxListTile(
                      value: isCompleted,
                      onChanged: (_) => onToggle(topic.name, isCompleted),
                      title: Text(
                        topic.name,
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
