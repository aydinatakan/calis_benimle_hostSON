import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // PRODUCTION - Hostinger
  // Backend dosyaları: public_html/calisbenimle/api klasöründe
  // Site URL: https://proje.cloud/calisbenimle/api
  // NOT: Eğer HTTPS çalışmıyorsa, geçici olarak HTTP kullanabilirsiniz:
  // static const String baseUrl = 'http://proje.cloud/calisbenimle/api';
  static const String baseUrl = 'http://192.168.1.164/calisbenimle_backend';
  
  // Token yönetimi
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('🔍 getToken() çağrıldı: ${token != null ? "Token var (${token.substring(0, 10)}...)" : "Token YOK!"}');
    return token;
  }
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('🟢 TOKEN KAYDEDILDI: ${token.substring(0, 10)}...');
  }
  
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Kullanıcı kaydı
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/register.php';
      print('🔵 REGISTER URL: $url');
      
      final requestBody = json.encode({
        'name': name,
        'email': email,
        'password': password,
      });
      print('🔵 REQUEST BODY: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );
      
      print('🔵 STATUS CODE: ${response.statusCode}');
      print('🔵 RESPONSE HEADERS: ${response.headers}');
      print('🔵 RESPONSE BODY (ilk 500 karakter): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}'
        };
      }
      
      // Response'un JSON olup olmadığını kontrol et
      final trimmedBody = response.body.trim();
      if (!trimmedBody.startsWith('{') && !trimmedBody.startsWith('[')) {
        print('🔴 HATA: API HTML döndürüyor, JSON bekleniyordu!');
        print('🔴 Response başlangıcı: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        return {
          'success': false,
          'message': 'Sunucu hatası: API yanıtı geçersiz. Lütfen sunucu ayarlarını kontrol edin.'
        };
      }
      
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('🔴 JSON decode hatası: $e');
        print('🔴 Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        return {
          'success': false,
          'message': 'Sunucu yanıtı geçersiz. Lütfen daha sonra tekrar deneyin.'
        };
      }
      
      // Register sonrası token KAYDEDİLMİYOR - Kullanıcı önce giriş yapmalı
      // Token sadece login sonrası kaydedilecek
      if (data['success'] == true) {
        print('✅ REGISTER BAŞARILI - Kullanıcı giriş yapmalı');
      } else {
        print('❌ REGISTER - Başarısız');
      }
      
      return data;
    } on SocketException catch (e) {
      print('🔴 REGISTER DNS/Bağlantı Hatası: $e');
      return {
        'success': false,
        'message': 'İnternet bağlantısı yok veya sunucu bulunamadı. Lütfen internet bağlantınızı kontrol edin ve domain ayarlarını doğrulayın.'
      };
    } catch (e, stackTrace) {
      print('🔴 REGISTER HATASI: $e');
      print('🔴 STACK TRACE: $stackTrace');
      
      String errorMessage = 'Bağlantı hatası oluştu.';
      if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
        errorMessage = 'Sunucu bulunamadı. Domain ayarlarını kontrol edin.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }
  
  // Kullanıcı girişi
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/login.php';
      print('🔵 LOGIN URL: $url');
      
      final requestBody = json.encode({
        'email': email,
        'password': password,
      });
      print('🔵 REQUEST BODY: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );
      
      print('🔵 STATUS CODE: ${response.statusCode}');
      print('🔵 RESPONSE HEADERS: ${response.headers}');
      print('🔵 RESPONSE BODY (ilk 500 karakter): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}'
        };
      }
      
      // Response'un JSON olup olmadığını kontrol et
      final trimmedBody = response.body.trim();
      if (!trimmedBody.startsWith('{') && !trimmedBody.startsWith('[')) {
        print('🔴 HATA: API HTML döndürüyor, JSON bekleniyordu!');
        print('🔴 Response başlangıcı: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        return {
          'success': false,
          'message': 'Sunucu hatası: API yanıtı geçersiz. Lütfen sunucu ayarlarını kontrol edin.'
        };
      }
      
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('🔴 JSON decode hatası: $e');
        print('🔴 Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        return {
          'success': false,
          'message': 'Sunucu yanıtı geçersiz. Lütfen daha sonra tekrar deneyin.'
        };
      }
      
      if (data['success'] == true && data['token'] != null) {
        await saveToken(data['token']);
      }
      
      return data;
    } on SocketException catch (e) {
      print('🔴 LOGIN DNS/Bağlantı Hatası: $e');
      return {
        'success': false,
        'message': 'İnternet bağlantısı yok veya sunucu bulunamadı. Lütfen internet bağlantınızı kontrol edin ve domain ayarlarını doğrulayın.'
      };
    } catch (e, stackTrace) {
      print('🔴 LOGIN HATASI: $e');
      print('🔴 STACK TRACE: $stackTrace');
      
      String errorMessage = 'Bağlantı hatası oluştu.';
      if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
        errorMessage = 'Sunucu bulunamadı. Domain ayarlarını kontrol edin.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }
  
  // Çıkış yapma
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token bulunamadı'};
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/logout.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'application/json',
        },
      );
      
      await deleteToken();
      
      return json.decode(response.body);
    } catch (e) {
      await deleteToken();
      return {'success': false, 'message': 'Çıkış hatası: $e'};
    }
  }
  
  // Genel GET isteği (token ile)
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await getToken();
      print('🔵 GET getToken(): ${token != null ? "Token var (${token.substring(0, 10)}...)" : "Token YOK!"}');
      if (token == null) {
        return {'success': false, 'message': 'Oturum bulunamadı'};
      }
      
      final url = '$baseUrl/$endpoint';
      final authHeader = 'Bearer $token';
      
      print('🔵 GET URL: $url');
      print('🔵 GET Authorization: Bearer ${token.substring(0, 10)}...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
          'User-Agent': 'CalisBenimle/1.0',
          'Accept': 'application/json',
        },
      );
      
      print('🔵 GET Response Status: ${response.statusCode}');
      print('🔵 GET Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      
      return json.decode(response.body);
    } catch (e) {
      print('🔴 GET Error: $e');
      return {'success': false, 'message': 'GET hatası: $e'};
    }
  }
  
  // Genel POST isteği (token ile)
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      print('🔵 POST getToken(): ${token != null ? "Token var (${token.substring(0, 10)}...)" : "Token YOK!"}');
      if (token == null) {
        return {'success': false, 'message': 'Oturum bulunamadı'};
      }
      
      final url = '$baseUrl/$endpoint';
      final authHeader = 'Bearer $token';
      
      print('🔵 POST URL: $url');
      print('🔵 POST Authorization: Bearer ${token.substring(0, 10)}...');
      print('🔵 POST Body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
          'User-Agent': 'CalisBenimle/1.0',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('🔵 POST Response Status: ${response.statusCode}');
      print('🔵 POST Response Body: ${response.body}');
      
      return json.decode(response.body);
    } catch (e) {
      print('🔴 POST Error: $e');
      return {'success': false, 'message': 'POST hatası: $e'};
    }
  }
  
  // Öğrenci tipi seçimi (token gerekli)
  Future<Map<String, dynamic>> setStudentType(String studentType) async {
    final body = <String, dynamic>{'student_type': studentType};
    
    // Token ile POST yap (token olmalı çünkü giriş yapılmış)
    return await post('set_student_type.php', body);
  }
  
  // Konuları getir
  Future<Map<String, dynamic>> getExamTopics() async {
    return await get('get_exam_topics.php');
  }
  
  // Deneme sonucu kaydet
  Future<Map<String, dynamic>> saveExamResult({
    required String examName,
    required String examDate,
    required String examType,
    required List<Map<String, dynamic>> subjects,
  }) async {
    return await post('save_exam_result.php', {
      'exam_name': examName,
      'exam_date': examDate,
      'exam_type': examType,
      'subjects': subjects,
    });
  }
  
  // Deneme sonuçlarını getir
  Future<Map<String, dynamic>> getExamResults() async {
    return await get('get_exam_results.php');
  }
  
  // Ders bazlı soru sayısı kaydet
  Future<Map<String, dynamic>> saveSubjectQuestionCount({
    required String examType,
    required String subject,
    required int questionCount,
  }) async {
    return await post('save_subject_question_count.php', {
      'exam_type': examType,
      'subject': subject,
      'question_count': questionCount,
    });
  }
  
  // Ders bazlı soru sayılarını getir
  Future<Map<String, dynamic>> getSubjectQuestionCounts() async {
    return await get('get_subject_question_counts.php');
  }
  
  // Takvim notu kaydet
  Future<Map<String, dynamic>> saveCalendarNote({
    required String noteDate,
    required String title,
    String? description,
  }) async {
    return await post('save_calendar_note.php', {
      'note_date': noteDate,
      'title': title,
      'description': description ?? '',
    });
  }
  
  // Takvim notlarını getir
  Future<Map<String, dynamic>> getCalendarNotes() async {
    return await get('get_calendar_notes.php');
  }
  
  // Yaklaşan anımsatıcıları getir
  Future<Map<String, dynamic>> getUpcomingReminders() async {
    return await get('get_upcoming_reminders.php');
  }
  
  // Aylık soru sayısı istatistiklerini getir
  Future<Map<String, dynamic>> getMonthlyQuestionStats() async {
    return await get('get_monthly_question_stats.php');
  }
}

