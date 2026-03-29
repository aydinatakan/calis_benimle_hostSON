import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/study_service.dart';
import '../services/api_service.dart';
import 'add_exam_result_screen.dart';
import 'exam_type_selection_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StudyService _studyService = StudyService();
  final ApiService _apiService = ApiService();
  Map<String, double> _weeklyStats = {};
  double _totalHours = 0;
  double _dailyAverage = 0;
  List<Map<String, dynamic>> _examResults = [];
  List<Map<String, dynamic>> _monthlyQuestionStats = [];
  String? _studentType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    print('📊 [STATISTICS] İstatistikler yükleniyor...');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final weeklyStats = await _studyService.getWeeklyStats();
      print('📊 [STATISTICS] Haftalık stats: $weeklyStats');
      
      final totalHours = await _studyService.getTotalHours();
      print('📊 [STATISTICS] Toplam saat: $totalHours');
      
      final dailyAverage = await _studyService.getDailyAverage();
      print('📊 [STATISTICS] Günlük ortalama: $dailyAverage');

      // Deneme sonuçlarını yükle
      final examResultsResponse = await _apiService.getExamResults();
      List<Map<String, dynamic>> examResults = [];
      if (examResultsResponse['success'] == true) {
        examResults = List<Map<String, dynamic>>.from(examResultsResponse['results'] ?? []);
      }

      // Öğrenci tipini al
      final topicsResponse = await _apiService.getExamTopics();
      String? studentType;
      if (topicsResponse['success'] == true) {
        studentType = topicsResponse['student_type'];
      }

      // Aylık soru sayısı istatistiklerini yükle
      List<Map<String, dynamic>> monthlyStats = [];
      try {
        final monthlyResponse = await _apiService.getMonthlyQuestionStats();
        if (monthlyResponse['success'] == true) {
          monthlyStats = List<Map<String, dynamic>>.from(monthlyResponse['monthly_stats'] ?? []);
        }
      } catch (e) {
        print('🔴 [STATISTICS] Aylık istatistikler yüklenemedi: $e');
      }

      // Deneme sonuçlarını tarihe göre sırala (eskiden yeniye)
      examResults.sort((a, b) {
        final dateA = a['exam_date'] as String? ?? '';
        final dateB = b['exam_date'] as String? ?? '';
        try {
          final dateTimeA = DateTime.parse(dateA);
          final dateTimeB = DateTime.parse(dateB);
          return dateTimeA.compareTo(dateTimeB);
        } catch (e) {
          return dateA.compareTo(dateB);
        }
      });

      setState(() {
        _weeklyStats = weeklyStats;
        _totalHours = totalHours;
        _dailyAverage = dailyAverage;
        _examResults = examResults;
        _monthlyQuestionStats = monthlyStats;
        _studentType = studentType;
        _isLoading = false;
      });
      
      print('✅ [STATISTICS] İstatistikler başarıyla yüklendi');
    } catch (e) {
      print('🔴 [STATISTICS] Hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addExamResult(String examType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExamResultScreen(examType: examType),
      ),
    );
    
    if (result == true) {
      _loadStats(); // Yeniden yükle
    }
  }

  Future<void> _showExamTypeSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExamTypeSelectionScreen(),
      ),
    );
    
    if (result == true) {
      _loadStats(); // Yeniden yükle
    }
  }

  BarChartData _buildMonthlyBarChart() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final maxQuestions = _monthlyQuestionStats.isEmpty
        ? 1.0
        : _monthlyQuestionStats
            .map((s) => (s['total_questions'] as int).toDouble())
            .reduce((a, b) => a > b ? a : b);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxQuestions * 1.2,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => colorScheme.primaryContainer,
          tooltipRoundedRadius: 8,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= _monthlyQuestionStats.length) {
                return const Text('');
              }
              final stat = _monthlyQuestionStats[value.toInt()];
              final month = stat['month'] as String;
              final monthParts = month.split('-');
              final monthNum = int.parse(monthParts[1]);
              final monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
                  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  monthNames[monthNum - 1],
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text('');
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxQuestions > 0 ? maxQuestions / 5 : 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.surfaceContainerHighest,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 1),
          left: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      barGroups: _monthlyQuestionStats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final total = stat['total_questions'] as int;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: total.toDouble(),
              color: colorScheme.primary,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getMonthName(String month) {
    final monthParts = month.split('-');
    final monthNum = int.parse(monthParts[1]);
    final year = monthParts[0];
    final monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${monthNames[monthNum - 1]} $year';
  }

  List<Widget> _buildExamNetChartsByType() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_examResults.isEmpty) {
      return [];
    }

    // Deneme sonuçlarını sınav tipine göre grupla
    final Map<String, List<Map<String, dynamic>>> resultsByType = {};
    for (var result in _examResults) {
      final examType = result['exam_type'] as String? ?? '';
      if (!resultsByType.containsKey(examType)) {
        resultsByType[examType] = [];
      }
      resultsByType[examType]!.add(result);
    }

    // YKS öğrencileri için sınav tiplerini sırala: TYT, AYT, YDS
    // LGS öğrencileri için sadece LGS
    final examTypes = _studentType == 'LGS' 
        ? ['LGS']
        : ['TYT', 'AYT', 'YDS'];

    List<Widget> charts = [];
    for (var examType in examTypes) {
      final typeResults = resultsByType[examType] ?? [];
      if (typeResults.isEmpty) continue;

      charts.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$examType Net Grafiği',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$examType deneme sonuçlarınızın net performansı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    _buildExamNetChartForType(typeResults, examType),
                  ),
                ),
                const SizedBox(height: 16),
                // Deneme listesi
                ...typeResults.map((result) {
                  final examName = result['exam_name'] as String? ?? '';
                  final examDate = result['exam_date'] as String? ?? '';
                  final totalNet = (result['total_net'] as num?)?.toDouble() ?? 0.0;
                  
                  DateTime? date;
                  String dateStr = examDate;
                  try {
                    date = DateTime.parse(examDate);
                    dateStr = DateFormat('dd MMM yyyy', 'tr_TR').format(date);
                  } catch (e) {
                    // Tarih parse edilemezse olduğu gibi göster
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                examName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                dateStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${totalNet.toStringAsFixed(2)} net',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getExamTypeColor(examType, colorScheme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      );
      charts.add(const SizedBox(height: 24));
    }

    return charts;
  }

  Color _getExamTypeColor(String examType, ColorScheme colorScheme) {
    switch (examType) {
      case 'TYT':
        return colorScheme.primary;
      case 'AYT':
        return colorScheme.secondary;
      case 'YDS':
        return colorScheme.tertiary;
      case 'LGS':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  List<Widget> _buildExamResultsByType() {
    if (_examResults.isEmpty) {
      return [];
    }

    // Deneme sonuçlarını sınav tipine göre grupla
    final Map<String, List<Map<String, dynamic>>> resultsByType = {};
    for (var result in _examResults) {
      final examType = result['exam_type'] as String? ?? '';
      if (!resultsByType.containsKey(examType)) {
        resultsByType[examType] = [];
      }
      resultsByType[examType]!.add(result);
    }

    // YKS öğrencileri için sınav tiplerini sırala: TYT, AYT, YDS
    // LGS öğrencileri için sadece LGS
    final examTypes = _studentType == 'LGS' 
        ? ['LGS']
        : ['TYT', 'AYT', 'YDS'];

    List<Widget> widgets = [];
    for (var examType in examTypes) {
      final typeResults = resultsByType[examType] ?? [];
      if (typeResults.isEmpty) continue;

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getExamTypeColor(examType, Theme.of(context).colorScheme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      examType,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getExamTypeColor(examType, Theme.of(context).colorScheme),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${typeResults.length} deneme)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ...typeResults.map((result) => _ExamResultCard(
              result: result,
            )).toList(),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return widgets;
  }

  BarChartData _buildExamNetChartForType(List<Map<String, dynamic>> results, String examType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (results.isEmpty) {
      return BarChartData();
    }

    final maxNet = results
        .map((r) => (r['total_net'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    final chartColor = _getExamTypeColor(examType, colorScheme);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxNet > 0 ? maxNet * 1.2 : 100,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => chartColor.withOpacity(0.2),
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final examName = results[group.x]['exam_name'] as String? ?? '';
            final net = (rod.toY).toStringAsFixed(2);
            return BarTooltipItem(
              '$examName\n$net net',
              TextStyle(
                color: chartColor,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= results.length) {
                return const Text('');
              }
              final examName = results[value.toInt()]['exam_name'] as String? ?? '';
              // İsim çok uzunsa kısalt
              final displayName = examName.length > 10 
                  ? '${examName.substring(0, 10)}...' 
                  : examName;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 9,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
            reservedSize: 60,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text('');
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxNet > 0 ? maxNet / 5 : 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.surfaceContainerHighest,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline, width: 1),
          left: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      barGroups: results.asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;
        final net = (result['total_net'] as num?)?.toDouble() ?? 0.0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: net,
              color: chartColor,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatHours(double hours) {
    if (hours == 0) return '0 dk';
    if (hours < 0.0167) { // 1 dakikadan az (0.0167 saat = 1 dakika)
      final seconds = (hours * 3600).round();
      return '$seconds sn';
    }
    if (hours < 1) { // 1 saatten az
      final minutes = (hours * 60).round();
      return '$minutes dk';
    }
    // 1 saat veya daha fazla
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m > 0) {
      return '${h}s ${m}dk';
    }
    return '${h}s';
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

    print('🔍 [STATISTICS UI] _weeklyStats: $_weeklyStats');
    print('🔍 [STATISTICS UI] _totalHours: $_totalHours');
    print('🔍 [STATISTICS UI] _dailyAverage: $_dailyAverage');

    final dailyStats = _weeklyStats.entries.map((e) => {
      'day': e.key,
      'hours': e.value,
    }).toList();

    final maxHours = dailyStats.isEmpty ? 1.0 : dailyStats.map((e) => e['hours'] as double).reduce((a, b) => a > b ? a : b);
    
    print('🔍 [STATISTICS UI] maxHours: $maxHours');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header
            Text(
              'İstatistikler',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Çalışma verileriniz ve analizler',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günlük Ortalama',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatHours(_dailyAverage),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Toplam Çalışma',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatHours(_totalHours),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Bar Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haftalık Çalışma Süresi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son 7 günün detaylı görünümü',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...dailyStats.map((stat) {
                      final day = stat['day'] as String;
                      final hours = stat['hours'] as double;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  day,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatHours(hours),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: maxHours > 0 ? hours / maxHours : 0.0,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Aylık Soru Sayısı Grafiği
            if (_monthlyQuestionStats.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aylık Çözülen Soru Sayısı',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Son 12 ayın detaylı görünümü',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          _buildMonthlyBarChart(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Aylık liste
                      ..._monthlyQuestionStats.map((stat) {
                        final month = stat['month'] as String;
                        final total = stat['total_questions'] as int;
                        final monthName = _getMonthName(month);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                monthName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$total soru',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Deneme Net Grafikleri (Sınav tipine göre ayrı)
            ..._buildExamNetChartsByType(),

            // Deneme Sonuçları Bölümü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deneme Sonuçları',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_studentType != null)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Öğrenci tipine göre sınav tipi belirle
                      if (_studentType == 'LGS') {
                        _addExamResult('LGS');
                      } else {
                        // YKS öğrencileri için sınav tipi seçim ekranına yönlendir
                        _showExamTypeSelection();
                      }
                    },
                    tooltip: 'Deneme Sonucu Ekle',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Deneme Sonuçları Listesi (Sınav tipine göre ayrı)
            if (_examResults.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz deneme sonucu eklenmemiş',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_studentType != null) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            if (_studentType == 'LGS') {
                              _addExamResult('LGS');
                            } else {
                              // YKS öğrencileri için sınav tipi seçim ekranına yönlendir
                              _showExamTypeSelection();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('İlk Deneme Sonucunu Ekle'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              ..._buildExamResultsByType(),

            const SizedBox(height: 24),

            // Refresh Button
            Center(
              child: OutlinedButton.icon(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Yenile'),
              ),
            ),
            const SizedBox(height: 100), // Bottom nav padding
          ],
        ),
      ),
    );
  }
}

class _ExamResultCard extends StatefulWidget {
  final Map<String, dynamic> result;

  const _ExamResultCard({
    required this.result,
  });

  @override
  State<_ExamResultCard> createState() => _ExamResultCardState();
}

class _ExamResultCardState extends State<_ExamResultCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final examDate = widget.result['exam_date'] as String? ?? '';
    final examName = widget.result['exam_name'] as String? ?? '';
    final examType = widget.result['exam_type'] as String? ?? '';
    final totalNet = (widget.result['total_net'] as num?)?.toDouble() ?? 0.0;
    final totalCorrect = widget.result['total_correct'] as int? ?? 0;
    final totalWrong = widget.result['total_wrong'] as int? ?? 0;
    final totalQuestions = widget.result['total_questions'] as int? ?? 0;
    final subjects = widget.result['subjects'] as List<dynamic>? ?? [];

    DateTime? date;
    try {
      date = DateTime.parse(examDate);
    } catch (e) {
      date = null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        examName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date != null
                            ? DateFormat('dd MMMM yyyy', 'tr_TR').format(date)
                            : examDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    examType,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Net',
                    value: totalNet.toStringAsFixed(2),
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Doğru',
                    value: totalCorrect.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Yanlış',
                    value: totalWrong.toString(),
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Toplam',
                    value: totalQuestions.toString(),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (subjects.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Detayları Gizle' : 'Detayları Göster',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Ders Detayları',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...subjects.map((subject) {
                  final subjectName = subject['subject'] as String? ?? '';
                  final questionCount = subject['question_count'] as int? ?? 0;
                  final correct = subject['correct'] as int? ?? 0;
                  final wrong = subject['wrong'] as int? ?? 0;
                  final net = (subject['net'] as num?)?.toDouble() ?? 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _SubjectStatItem(
                                  label: 'Doğru',
                                  value: correct.toString(),
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _SubjectStatItem(
                                  label: 'Yanlış',
                                  value: wrong.toString(),
                                  color: Colors.red,
                                ),
                              ),
                              Expanded(
                                child: _SubjectStatItem(
                                  label: 'Net',
                                  value: net.toStringAsFixed(2),
                                  color: colorScheme.primary,
                                ),
                              ),
                              Expanded(
                                child: _SubjectStatItem(
                                  label: 'Toplam',
                                  value: questionCount.toString(),
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SubjectStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SubjectStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}


