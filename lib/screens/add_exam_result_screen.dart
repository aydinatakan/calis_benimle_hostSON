import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AddExamResultScreen extends StatefulWidget {
  final String examType;
  
  const AddExamResultScreen({super.key, required this.examType});

  @override
  State<AddExamResultScreen> createState() => _AddExamResultScreenState();
}

class _AddExamResultScreenState extends State<AddExamResultScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  DateTime? _selectedDate;
  final Map<String, Map<String, TextEditingController>> _subjectControllers = {};
  final List<String> _subjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSubjects();
  }

  void _initializeSubjects() {
    // Sınav tipine göre dersleri belirle
    if (widget.examType == 'LGS') {
      _subjects.addAll([
        'Türkçe',
        'Matematik',
        'Fen Bilimleri',
        'İnkılap Tarihi',
        'Din Kültürü',
        'İngilizce',
      ]);
    } else if (widget.examType == 'TYT') {
      // TYT: Türkçe, Matematik ile Geometri (birleşik), Sosyal (Tarih, Coğrafya, Felsefe, Din Kültürü), Fen (Fizik, Kimya, Biyoloji)
      _subjects.addAll([
        'Türkçe',
        'Matematik ile Geometri',
        'Sosyal Bilimler',
        'Fen Bilimleri',
      ]);
    } else if (widget.examType == 'AYT') {
      // AYT: Türk Dili ve Edebiyatı-Sosyal Bilimler-1 Testi, Sosyal Bilimler-2, Matematik, Fen Bilimleri Testi
      _subjects.addAll([
        'Türk Dili ve Edebiyatı-Sosyal Bilimler-1 Testi',
        'Sosyal Bilimler-2',
        'Matematik',
        'Fen Bilimleri Testi',
      ]);
    } else if (widget.examType == 'YDS') {
      _subjects.addAll(['Test of English']);
    }

    // Her ders için controller'lar oluştur
    for (var subject in _subjects) {
      _subjectControllers[subject] = {
        'question': TextEditingController(),
        'correct': TextEditingController(),
        'wrong': TextEditingController(),
      };
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    for (var controllers in _subjectControllers.values) {
      controllers['question']?.dispose();
      controllers['correct']?.dispose();
      controllers['wrong']?.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveResult() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen deneme tarihini seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Ders verilerini hazırla
    List<Map<String, dynamic>> subjects = [];
    for (var subject in _subjects) {
      final controllers = _subjectControllers[subject]!;
      final questionCount = int.tryParse(controllers['question']!.text) ?? 0;
      final correct = int.tryParse(controllers['correct']!.text) ?? 0;
      final wrong = int.tryParse(controllers['wrong']!.text) ?? 0;

      if (questionCount > 0) {
        subjects.add({
          'subject': subject,
          'question_count': questionCount,
          'correct': correct,
          'wrong': wrong,
        });
      }
    }

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir ders için veri girmelisiniz')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await _apiService.saveExamResult(
      examName: _examNameController.text.trim(),
      examDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      examType: widget.examType,
      subjects: subjects,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success']) {
        Navigator.pop(context, true); // Başarılı, geri dön
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Kayıt başarısız')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examType} Deneme Sonucu Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deneme Adı
              TextFormField(
                controller: _examNameController,
                decoration: const InputDecoration(
                  labelText: 'Deneme Adı',
                  hintText: 'Örn: 2026 TYT Deneme 1',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deneme adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tarih Seçimi
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deneme Tarihi',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate!)
                        : 'Tarih seçin',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Dersler
              Text(
                'Ders Sonuçları',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ..._subjects.map((subject) => _SubjectInputCard(
                subject: subject,
                controllers: _subjectControllers[subject]!,
              )).toList(),

              const SizedBox(height: 24),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveResult,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectInputCard extends StatelessWidget {
  final String subject;
  final Map<String, TextEditingController> controllers;

  const _SubjectInputCard({
    required this.subject,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers['question'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Soru',
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Geçersiz';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['correct'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Doğru',
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Geçersiz';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['wrong'],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Yanlış',
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 0) {
                          return 'Geçersiz';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

