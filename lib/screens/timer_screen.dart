import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/study_session.dart';
import '../services/study_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final StudyService _studyService = StudyService();
  
  // Timer mode: 'stopwatch' or 'countdown'
  String _timerMode = 'stopwatch';
  
  // Stopwatch (counting up)
  Timer? _stopwatchTimer;
  int _stopwatchSeconds = 0;
  bool _isStopwatchRunning = false;

  // Countdown timer
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  int _countdownInitialSeconds = 0; // Başlangıç süresi
  bool _isCountdownRunning = false;
  final _countdownController = TextEditingController();

  // Study statistics
  StudySession? _lastSession;
  double _todayHours = 0.0;
  double _weekHours = 0.0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStudyStats();
  }

  Future<void> _loadStudyStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final sessions = await _studyService.getStudySessions();
      
      if (sessions.isNotEmpty) {
        // En son çalışma
        _lastSession = sessions.first;
        
        // Bugünkü toplam
        final today = DateTime.now();
        final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        _todayHours = sessions
            .where((s) => s.dateKey == todayKey)
            .fold<double>(0.0, (sum, s) => sum + s.hours);
        
        // Haftalık toplam (son 7 gün)
        final weekAgo = today.subtract(const Duration(days: 7));
        _weekHours = sessions
            .where((s) => s.date.isAfter(weekAgo))
            .fold<double>(0.0, (sum, s) => sum + s.hours);
      }
    } catch (e) {
      print('🔴 [TIMER] İstatistik yükleme hatası: $e');
    }

    setState(() {
      _isLoadingStats = false;
    });
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _countdownController.dispose();
    super.dispose();
  }

  void _toggleStopwatch() {
    if (_isStopwatchRunning) {
      _stopwatchTimer?.cancel();
      setState(() {
        _isStopwatchRunning = false;
      });
    } else {
      // Geri sayım çalışıyorsa önce onu durdur
      if (_isCountdownRunning) {
        _countdownTimer?.cancel();
        setState(() {
          _isCountdownRunning = false;
        });
      }
      
      setState(() {
        _isStopwatchRunning = true;
      });
      _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _stopwatchSeconds++;
        });
      });
    }
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _isStopwatchRunning = false;
      _stopwatchSeconds = 0;
    });
  }

  Future<void> _saveStopwatchSession() async {
    if (_stopwatchSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilecek süre yok!')),
      );
      return;
    }

    print('🟡 [TIMER] Çalışma kaydediliyor: $_stopwatchSeconds saniye');

    final session = StudySession(
      date: DateTime.now(),
      durationInSeconds: _stopwatchSeconds,
    );

    print('🟡 [TIMER] StudySession oluşturuldu: ${session.toJson()}');

    try {
      final result = await _studyService.saveStudySession(session);
      
      print('🟡 [TIMER] Backend response: $result');

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_formatTime(_stopwatchSeconds)} çalışma kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
          _resetStopwatch();
          _loadStudyStats(); // İstatistikleri yenile
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Kaydetme başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('🔴 [TIMER] Kaydetme hatası: $e');
      print('🔴 [TIMER] Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startCountdown() {
    final minutes = int.tryParse(_countdownController.text);
    if (minutes != null && minutes > 0) {
      // Kronometre çalışıyorsa önce onu durdur
      if (_isStopwatchRunning) {
        _stopwatchTimer?.cancel();
        setState(() {
          _isStopwatchRunning = false;
        });
      }
      
      setState(() {
        _countdownInitialSeconds = minutes * 60;
        _countdownSeconds = _countdownInitialSeconds;
        _isCountdownRunning = true;
      });
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdownSeconds <= 1) {
            _countdownTimer?.cancel();
            _isCountdownRunning = false;
            _countdownSeconds = 0;
            _countdownInitialSeconds = 0;
          } else {
            _countdownSeconds--;
          }
        });
      });
    }
  }

  void _toggleCountdown() {
    if (_isCountdownRunning) {
      _countdownTimer?.cancel();
      setState(() {
        _isCountdownRunning = false;
      });
    } else {
      // Kronometre çalışıyorsa önce onu durdur
      if (_isStopwatchRunning) {
        _stopwatchTimer?.cancel();
        setState(() {
          _isStopwatchRunning = false;
        });
      }
      
      if (_countdownSeconds == 0) {
        _startCountdown();
      } else {
        setState(() {
          _isCountdownRunning = true;
        });
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_countdownSeconds <= 1) {
              _countdownTimer?.cancel();
              _isCountdownRunning = false;
              _countdownSeconds = 0;
              _countdownInitialSeconds = 0;
            } else {
              _countdownSeconds--;
            }
          });
        });
      }
    }
  }

  void _resetCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownRunning = false;
      _countdownSeconds = 0;
      _countdownInitialSeconds = 0;
      _countdownController.clear();
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            
            // Unified Timer Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Mode Selector
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: 'Kronometre',
                              icon: Icons.timer,
                              isSelected: _timerMode == 'stopwatch',
                              onTap: () {
                                setState(() {
                                  _timerMode = 'stopwatch';
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _ModeButton(
                              label: 'Geri Sayım',
                              icon: Icons.hourglass_empty,
                              isSelected: _timerMode == 'countdown',
                              onTap: () {
                                setState(() {
                                  _timerMode = 'countdown';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Timer Display with Circular Progress
                    SizedBox(
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Progress Background
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: _timerMode == 'stopwatch'
                                  ? (_stopwatchSeconds > 0 ? 1.0 : 0.0)
                                  : (_countdownInitialSeconds > 0
                                      ? 1.0 - (_countdownSeconds / _countdownInitialSeconds)
                                      : 0.0),
                              strokeWidth: 8,
                              backgroundColor: (_timerMode == 'stopwatch'
                                      ? colorScheme.primary
                                      : colorScheme.secondary)
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _timerMode == 'stopwatch'
                                    ? colorScheme.primary
                                    : colorScheme.secondary,
                              ),
                            ),
                          ),
                          // Timer Content
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _timerMode == 'stopwatch'
                                    ? [
                                        colorScheme.primaryContainer,
                                        colorScheme.primaryContainer.withOpacity(0.7),
                                      ]
                                    : [
                                        colorScheme.secondaryContainer,
                                        colorScheme.secondaryContainer.withOpacity(0.7),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_timerMode == 'stopwatch'
                                          ? colorScheme.primary
                                          : colorScheme.secondary)
                                      .withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _timerMode == 'stopwatch'
                                      ? _formatTime(_stopwatchSeconds)
                                      : _formatTime(_countdownSeconds),
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _timerMode == 'stopwatch'
                                        ? colorScheme.primary
                                        : colorScheme.secondary,
                                    fontFamily: 'monospace',
                                    fontSize: 48,
                                    letterSpacing: 2,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _timerMode == 'stopwatch'
                                      ? 'Çalışma Süresi'
                                      : 'Kalan Süre',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: (_timerMode == 'stopwatch'
                                            ? colorScheme.primary
                                            : colorScheme.secondary)
                                        .withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Countdown Input (only for countdown mode)
                    if (_timerMode == 'countdown') ...[
                      TextField(
                        controller: _countdownController,
                        keyboardType: TextInputType.number,
                        enabled: !_isCountdownRunning && _countdownSeconds == 0,
                        decoration: InputDecoration(
                          labelText: 'Dakika girin',
                          hintText: 'Örn: 25',
                          prefixIcon: const Icon(Icons.timer_outlined),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _timerMode == 'stopwatch'
                              ? _toggleStopwatch
                              : _toggleCountdown,
                          icon: Icon(
                            (_timerMode == 'stopwatch'
                                    ? _isStopwatchRunning
                                    : _isCountdownRunning)
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            (_timerMode == 'stopwatch'
                                    ? _isStopwatchRunning
                                    : _isCountdownRunning)
                                ? 'Duraklat'
                                : 'Başlat',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(140, 56),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: _timerMode == 'stopwatch'
                                ? colorScheme.primary
                                : colorScheme.secondary,
                            foregroundColor: _timerMode == 'stopwatch'
                                ? colorScheme.onPrimary
                                : colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _timerMode == 'stopwatch'
                              ? _resetStopwatch
                              : _resetCountdown,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Sıfırla'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(140, 56),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            foregroundColor: _timerMode == 'stopwatch'
                                ? colorScheme.primary
                                : colorScheme.secondary,
                            side: BorderSide(
                              color: _timerMode == 'stopwatch'
                                  ? colorScheme.primary
                                  : colorScheme.secondary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Save Button (only for stopwatch mode)
                    if (_timerMode == 'stopwatch' &&
                        _stopwatchSeconds > 0 &&
                        !_isStopwatchRunning) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saveStopwatchSession,
                        icon: const Icon(Icons.save),
                        label: const Text('Çalışmayı Kaydet'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Study Statistics Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insights,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Çalışma İstatistikleri',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    if (_isLoadingStats)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_lastSession == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.timer_off,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Henüz çalışma kaydı yok',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Son Çalışma
                      _StatCard(
                        icon: Icons.access_time,
                        title: 'Son Çalışma',
                        value: _formatTime(_lastSession!.durationInSeconds),
                        subtitle: DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR')
                            .format(_lastSession!.date),
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      
                      // Bugünkü Toplam
                      _StatCard(
                        icon: Icons.today,
                        title: 'Bugünkü Toplam',
                        value: _formatDuration(_todayHours),
                        subtitle: _todayHours > 0
                            ? 'Harika! Devam et! 💪'
                            : 'Henüz bugün çalışma yok',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      
                      // Haftalık Toplam
                      _StatCard(
                        icon: Icons.calendar_view_week,
                        title: 'Haftalık Toplam',
                        value: _formatDuration(_weekHours),
                        subtitle: 'Son 7 günün toplamı',
                        color: colorScheme.secondary,
                      ),
                    ],
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

  String _formatDuration(double hours) {
    if (hours == 0) return '0 dk';
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes dk';
    }
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m > 0) {
      return '${h}s ${m}dk';
    }
    return '${h}s';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

