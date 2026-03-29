import 'dart:async';
import 'package:flutter/material.dart';

/// A standalone page that displays live countdowns for TYT and AYT exams
/// Uses only DateTime calculations, no external dependencies
class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});

  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  // Timer that updates every second
  Timer? _timer;

  // Exam dates - fixed dates, no storage needed
  final DateTime _tytExamDate = DateTime(2026, 6, 20, 10, 0); // June 20, 2026 at 10:00 AM
  final DateTime _aytExamDate = DateTime(2026, 6, 21, 10, 0); // June 21, 2026 at 10:00 AM

  // Current time difference values (recalculated every second)
  Duration _tytRemaining = Duration.zero;
  Duration _aytRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Calculate initial values
    _updateCountdowns();
    
    // Start timer that updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCountdowns();
        });
      }
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel timer to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  /// Calculates time remaining for both exams using DateTime.difference()
  void _updateCountdowns() {
    final now = DateTime.now();
    
    // Calculate difference between exam date and current time
    final tytDiff = _tytExamDate.difference(now);
    final aytDiff = _aytExamDate.difference(now);
    
    // If negative (exam passed), set to zero
    _tytRemaining = tytDiff.isNegative ? Duration.zero : tytDiff;
    _aytRemaining = aytDiff.isNegative ? Duration.zero : aytDiff;
  }

  /// Formats Duration to "X days X hours X minutes X seconds"
  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return 'Sınav Geçti';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '$days gün $hours saat $minutes dakika $seconds saniye';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YKS Sınav Geri Sayımı'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header text
              Text(
                'Sınav Tarihine Kalan Süre',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hedefine ulaşmak için çalışmaya devam et! 💪',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // TYT Countdown Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // TYT Icon and Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'TYT SINAVI',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Exam Date
                      Text(
                        '20 Haziran 2026',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Countdown Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(_tytRemaining),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AYT Countdown Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // AYT Icon and Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 32,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'AYT SINAVI',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Exam Date
                      Text(
                        '21 Haziran 2026',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Countdown Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(_aytRemaining),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Motivational message
              Card(
                color: colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Her gün biraz daha yaklaşıyorsun! Düzenli çalışma başarının anahtarı.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

