import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/study_service.dart';
import '../services/api_service.dart';
import '../models/study_session.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final Function(int) onNavigateToTab;
  
  const HomeScreen({
    super.key, 
    required this.onLogout,
    required this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StudyService _studyService = StudyService();
  final ApiService _apiService = ApiService();
  String _userName = '';
  double _todayHours = 0;
  double _totalHours = 0;
  List<StudySession> _recentSessions = [];
  List<Map<String, dynamic>> _upcomingReminders = [];
  Set<int> _shownReminderIds = {}; // Gösterilmiş anımsatıcı ID'leri
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Her 5 dakikada bir anımsatıcıları kontrol et
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    // Her 5 dakikada bir anımsatıcıları kontrol et
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        _checkReminders();
        _startPeriodicCheck(); // Tekrar başlat
      }
    });
  }

  Future<void> _checkReminders() async {
    try {
      final remindersResponse = await _apiService.getUpcomingReminders();
      if (remindersResponse['success'] == true) {
        final reminders = List<Map<String, dynamic>>.from(remindersResponse['reminders'] ?? []);
        if (mounted) {
          // Yeni anımsatıcıları bul (daha önce gösterilmemiş olanlar)
          final newReminders = reminders.where((r) {
            final id = r['id'] as int?;
            return id != null && !_shownReminderIds.contains(id);
          }).toList();
          
          // Yeni anımsatıcılar varsa bildirim göster
          if (newReminders.isNotEmpty) {
            _showReminderNotification(newReminders);
            // Gösterilen ID'leri kaydet
            for (var reminder in newReminders) {
              final id = reminder['id'] as int?;
              if (id != null) {
                _shownReminderIds.add(id);
              }
            }
          }
          
          setState(() {
            _upcomingReminders = reminders;
          });
        }
      }
    } catch (e) {
      print('🔴 [HOME] Anımsatıcı kontrolü hatası: $e');
    }
  }

  void _showReminderNotification(List<Map<String, dynamic>> reminders) {
    // En yakın anımsatıcıyı bul
    DateTime? nearestDate;
    String? nearestTitle;
    int? nearestId;
    
    for (var reminder in reminders) {
      final noteDate = reminder['note_date'] as String? ?? '';
      try {
        final date = DateTime.parse(noteDate);
        if (nearestDate == null || date.isBefore(nearestDate)) {
          nearestDate = date;
          nearestTitle = reminder['title'] as String? ?? '';
          nearestId = reminder['id'] as int?;
        }
      } catch (e) {
        continue;
      }
    }
    
    if (nearestDate != null && nearestTitle != null) {
      final now = DateTime.now();
      final difference = nearestDate.difference(now);
      
      String message = '';
      if (difference.inDays > 0) {
        message = '$nearestTitle için ${difference.inDays} gün kaldı';
      } else if (difference.inHours > 0) {
        message = '$nearestTitle için ${difference.inHours} saat kaldı';
      } else if (difference.inMinutes > 0) {
        message = '$nearestTitle için ${difference.inMinutes} dakika kaldı';
      } else {
        message = '$nearestTitle şimdi!';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Görüntüle',
              textColor: Colors.white,
              onPressed: () {
                widget.onNavigateToTab(2); // Takvim sekmesine git
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadData() async {
    print('🏠 [HOME] Veri yükleniyor...');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Kullanıcı adını yükle
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'Öğrenci';
      print('🏠 [HOME] Kullanıcı adı: $name');
      
      // Bugünkü çalışma süresini hesapla
      final sessions = await _studyService.getStudySessions();
      print('🏠 [HOME] Toplam ${sessions.length} seans bulundu');
      
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      print('🏠 [HOME] Bugünkü tarih anahtarı: $todayKey');
      
      double todayHours = 0;
      int todaySessionCount = 0;
      for (var session in sessions) {
        print('🏠 [HOME] Seans: ${session.dateKey}, ${session.hours} saat');
        if (session.dateKey == todayKey) {
          todayHours += session.hours;
          todaySessionCount++;
          print('✅ [HOME] Bugüne ait seans bulundu!');
        }
      }
      
      print('🏠 [HOME] Bugünkü toplam: $todaySessionCount seans, $todayHours saat');
      
      // Toplam çalışma süresini hesapla
      double totalHours = 0;
      for (var session in sessions) {
        totalHours += session.hours;
      }
      print('🏠 [HOME] Genel toplam: $totalHours saat');
      
      // Son 3 çalışmayı al
      final recentSessions = sessions.take(3).toList();
      print('🏠 [HOME] Son 3 seans alındı');
      
      // Yaklaşan anımsatıcıları yükle
      List<Map<String, dynamic>> reminders = [];
      try {
        final remindersResponse = await _apiService.getUpcomingReminders();
        if (remindersResponse['success'] == true) {
          reminders = List<Map<String, dynamic>>.from(remindersResponse['reminders'] ?? []);
        }
      } catch (e) {
        print('🔴 [HOME] Anımsatıcılar yüklenemedi: $e');
      }
      
      setState(() {
        _userName = name;
        _todayHours = todayHours;
        _totalHours = totalHours;
        _recentSessions = recentSessions;
        _upcomingReminders = reminders;
        _isLoading = false;
      });
      
      print('✅ [HOME] Veri yükleme tamamlandı');
    } catch (e, stackTrace) {
      print('🔴 [HOME] Hata: $e');
      print('🔴 [HOME] Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(double hours) {
    if (hours == 0) return '0 dk';
    
    // 1 dakikadan az ise saniye göster
    if (hours < 0.0167) { // 0.0167 saat = 1 dakika
      final seconds = (hours * 3600).round();
      return '$seconds sn';
    }
    
    // 1 saatten az ise dakika göster
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '$minutes dk';
    }
    
    // 1 saat veya daha fazla ise saat:dakika göster
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (m > 0) {
      return '${h}s ${m}dk';
    }
    return '${h}s';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 1) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 12),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                widget.onLogout();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş geldin, $_userName! 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now()),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Stats
            Text(
              'Bugünkü Özet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer,
                    label: 'Bugün',
                    value: _formatDuration(_todayHours),
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Toplam Çalışma',
                    value: _formatDuration(_totalHours),
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Yaklaşan Etkinlikler (24 saat içinde)
            if (_upcomingReminders.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.notifications_active, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Yaklaşan Etkinlikler',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._upcomingReminders.map((reminder) {
                final noteDate = reminder['note_date'] as String? ?? '';
                final title = reminder['title'] as String? ?? '';
                final description = reminder['description'] as String? ?? '';
                
                DateTime? date;
                try {
                  date = DateTime.parse(noteDate);
                } catch (e) {
                  date = null;
                }
                
                // Kalan süreyi hesapla
                String timeRemaining = '';
                Color? urgencyColor;
                if (date != null) {
                  final now = DateTime.now();
                  final difference = date.difference(now);
                  
                  if (difference.inDays > 0) {
                    timeRemaining = '${difference.inDays} gün kaldı';
                    urgencyColor = colorScheme.primary;
                  } else if (difference.inHours > 0) {
                    timeRemaining = '${difference.inHours} saat kaldı';
                    urgencyColor = colorScheme.error;
                  } else if (difference.inMinutes > 0) {
                    timeRemaining = '${difference.inMinutes} dakika kaldı';
                    urgencyColor = colorScheme.error;
                  } else {
                    timeRemaining = 'Şimdi!';
                    urgencyColor = colorScheme.error;
                  }
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: urgencyColor?.withOpacity(0.1) ?? colorScheme.secondaryContainer,
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: urgencyColor ?? colorScheme.secondary,
                      child: Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description.isNotEmpty) ...[
                          Text(description),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: urgencyColor ?? colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date != null
                                  ? '${DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(date)} • $timeRemaining'
                                  : noteDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: urgencyColor ?? colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: urgencyColor != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: urgencyColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              timeRemaining,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.notifications_active,
                            color: colorScheme.secondary,
                          ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],

            // Quick Actions
            Text(
              'Hızlı İşlemler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.play_arrow,
                    label: 'Çalışmaya Başla',
                    color: colorScheme.primaryContainer,
                    onTap: () => widget.onNavigateToTab(1), // Timer ekranı
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add,
                    label: 'Yeni Konu Ekle',
                    color: colorScheme.secondaryContainer,
                    onTap: () => widget.onNavigateToTab(3), // Konular ekranı
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activities
            Text(
              'Son Çalışmalar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_recentSessions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.timer_off, size: 48, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz çalışma kaydın yok',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recentSessions.map((session) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecentActivityCard(
                  subject: 'Çalışma',
                  topic: DateFormat('d MMMM yyyy', 'tr_TR').format(session.date),
                  duration: _formatDuration(session.hours),
                  time: _getTimeAgo(session.date),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final String subject;
  final String topic;
  final String duration;
  final String time;

  const _RecentActivityCard({
    required this.subject,
    required this.topic,
    required this.duration,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.book, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(topic),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              duration,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

