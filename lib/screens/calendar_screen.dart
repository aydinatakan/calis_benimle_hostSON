import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/study_service.dart';
import '../services/api_service.dart';
import 'add_calendar_note_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StudyService _studyService = StudyService();
  final ApiService _apiService = ApiService();
  DateTime _currentDate = DateTime.now();
  Set<String> _studyDays = {};
  Map<String, Map<String, dynamic>> _calendarNotes = {}; // "YYYY-MM-DD" -> {title, description}
  Timer? _countdownTimer;
  String? _studentType;
  
  // Sınav tarihleri
  final DateTime _lgsExamDate = DateTime(2026, 6, 14);
  final DateTime _tytExamDate = DateTime(2026, 6, 20);
  final DateTime _aytExamDate = DateTime(2026, 6, 21);

  @override
  void initState() {
    super.initState();
    _loadData();
    _startCountdownTimer();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadStudyDays(),
      _loadCalendarNotes(),
      _loadStudentType(),
    ]);
  }

  Future<void> _loadStudentType() async {
    try {
      final response = await _apiService.getExamTopics();
      if (response['success'] == true) {
        setState(() {
          _studentType = response['student_type'];
        });
      }
    } catch (e) {
      print('🔴 [CALENDAR] Öğrenci tipi yüklenemedi: $e');
    }
  }

  Future<void> _loadCalendarNotes() async {
    try {
      final response = await _apiService.getCalendarNotes();
      if (response['success'] == true) {
        final notes = response['notes'] as List;
        final notesMap = <String, Map<String, dynamic>>{};
        for (var note in notes) {
          notesMap[note['note_date']] = {
            'title': note['title'],
            'description': note['description'],
            'id': note['id'],
          };
        }
        setState(() {
          _calendarNotes = notesMap;
        });
      }
    } catch (e) {
      print('🔴 [CALENDAR] Takvim notları yüklenemedi: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadStudyDays() async {
    final days = await _studyService.getStudyDays();
    setState(() {
      _studyDays = days;
    });
  }

  String _getCountdownText(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);
    
    if (difference.isNegative) {
      return 'Sınav Geçti';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return '$days gün $hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final List<String> _monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  final List<String> _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }


  bool _isStudyDay(int day) {
    final dateStr = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return _studyDays.contains(dateStr);
  }

  bool _hasNote(int day) {
    final dateStr = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return _calendarNotes.containsKey(dateStr);
  }

  Map<String, dynamic>? _getNote(int day) {
    final dateStr = '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return _calendarNotes[dateStr];
  }

  Future<void> _onDayTap(int day) async {
    final selectedDate = DateTime(_currentDate.year, _currentDate.month, day);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCalendarNoteScreen(
          selectedDate: selectedDate,
          existingNote: _getNote(day),
        ),
      ),
    );

    if (result == true) {
      _loadCalendarNotes(); // Yeniden yükle
    }
  }

  bool _isToday(int day) {
    final today = DateTime.now();
    return today.day == day &&
        today.month == _currentDate.month &&
        today.year == _currentDate.year;
  }

  int _getStudyDaysThisMonth() {
    return _studyDays.where((date) {
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return year == _currentDate.year && month == _currentDate.month;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    int firstWeekday = firstDayOfMonth.weekday - 1;
    if (firstWeekday == -1) firstWeekday = 6;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header
            Text(
              'Takvim',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Çalışma günleriniz ve sınav geri sayımı',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Exam Countdowns
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // LGS Countdown (sadece LGS öğrencisi için)
                    if (_studentType == 'LGS') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LGS Sınavı',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '14 Haziran 2026',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCountdownText(_lgsExamDate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.tertiary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                    ],
                    // TYT Countdown (YKS öğrencisi için)
                    if (_studentType == 'YKS') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TYT Sınavı',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '20 Haziran 2026',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCountdownText(_tytExamDate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      // AYT Countdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AYT Sınavı',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '21 Haziran 2026',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCountdownText(_aytExamDate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu ay çalışılan gün sayısı',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_getStudyDaysThisMonth()} gün',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Calendar Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Month Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          '${_monthNames[_currentDate.month - 1]} ${_currentDate.year}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Day Names
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dayNames.map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Calendar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: firstWeekday + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < firstWeekday) {
                          return const SizedBox();
                        }
                        
                        final day = index - firstWeekday + 1;
                        final isStudied = _isStudyDay(day);
                        final isTodayDate = _isToday(day);
                        final hasNote = _hasNote(day);
                        final note = _getNote(day);

                        return InkWell(
                          onTap: () => _onDayTap(day),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isStudied ? colorScheme.primaryContainer : null,
                              border: Border.all(
                                color: isTodayDate ? colorScheme.primary : colorScheme.outlineVariant,
                                width: isTodayDate ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isTodayDate ? FontWeight.bold : FontWeight.normal,
                                    color: isStudied ? colorScheme.primary : null,
                                  ),
                                ),
                                if (isStudied)
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                if (hasNote)
                                  Icon(
                                    Icons.note,
                                    size: 12,
                                    color: colorScheme.secondary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Çalışma günleri zamanlayıcıdan kaydedildiğinde otomatik işaretlenir',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

