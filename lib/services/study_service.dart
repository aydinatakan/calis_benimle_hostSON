import '../models/study_session.dart';
import 'api_service.dart';

class StudyService {
  final ApiService _api = ApiService();

  // Çalışma seansını backend'e kaydet
  Future<Map<String, dynamic>> saveStudySession(StudySession session) async {
    print('🟢 [STUDY_SERVICE] saveStudySession çağrıldı');
    print('🟢 [STUDY_SERVICE] Session data: ${session.toJson()}');
    
    final requestData = {
      'date': session.date.toIso8601String(),
      'durationInSeconds': session.durationInSeconds,
    };
    
    print('🟢 [STUDY_SERVICE] API\'ye gönderilen veri: $requestData');
    
    final result = await _api.post('save_session.php', requestData);
    
    print('🟢 [STUDY_SERVICE] Backend response: $result');
    
    return result;
  }

  // Tüm çalışma seanslarını backend'den getir
  Future<List<StudySession>> getStudySessions() async {
    print('🟢 [STUDY_SERVICE] getStudySessions çağrıldı');
    
    final result = await _api.get('get_sessions.php');
    
    print('🟢 [STUDY_SERVICE] Backend response: $result');
    
    if (result['success'] == true && result['sessions'] != null) {
      final List<dynamic> sessionsJson = result['sessions'];
      final sessions = sessionsJson.map((json) => StudySession.fromJson(json)).toList();
      
      print('🟢 [STUDY_SERVICE] ${sessions.length} seans bulundu');
      
      return sessions;
    }
    
    print('⚠️ [STUDY_SERVICE] Hiç seans bulunamadı');
    return [];
  }

  // Haftalık istatistikleri backend'den getir
  Future<Map<String, double>> getWeeklyStats() async {
    final result = await _api.get('get_weekly_stats.php');
    
    if (result['success'] == true && result['weeklyStats'] != null) {
      final Map<String, dynamic> statsJson = result['weeklyStats'];
      return statsJson.map((key, value) => MapEntry(key, (value as num).toDouble()));
    }
    
    return {
      'Pazartesi': 0.0,
      'Salı': 0.0,
      'Çarşamba': 0.0,
      'Perşembe': 0.0,
      'Cuma': 0.0,
      'Cumartesi': 0.0,
      'Pazar': 0.0,
    };
  }

  // Çalışma yapılan günleri backend'den getir
  Future<Set<String>> getStudyDays() async {
    final result = await _api.get('get_study_days.php');
    
    if (result['success'] == true && result['studyDays'] != null) {
      final List<dynamic> days = result['studyDays'];
      return days.map((day) => day.toString()).toSet();
    }
    
    return {};
  }

  // Toplam çalışma saati
  Future<double> getTotalHours() async {
    final sessions = await getStudySessions();
    return sessions.fold<double>(0.0, (sum, session) => sum + session.hours);
  }

  // Günlük ortalama çalışma saati
  Future<double> getDailyAverage() async {
    final sessions = await getStudySessions();
    if (sessions.isEmpty) return 0.0;
    
    final uniqueDays = sessions.map((s) => s.dateKey).toSet().length;
    final double totalHours = await getTotalHours();
    
    return uniqueDays > 0 ? totalHours / uniqueDays : 0.0;
  }
}

