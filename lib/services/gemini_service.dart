import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';

class GeminiService {
  // Gemini API Key - https://aistudio.google.com/app/apikey adresinden alın
  // NOT: API key'i buraya ekleyin: 'YOUR_API_KEY_HERE'
  static const String _apiKey = 'AIzaSyDvcqi3diM2wAlY3aCvxwZPCqBU2SZ82Ng';
  
  // API key kontrolü - placeholder ile karşılaştır
  bool get isApiKeyConfigured => _apiKey != 'BURAYA_API_KEY_YAZ' && _apiKey.isNotEmpty;
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    print('🤖 [GEMINI] Service başlatılıyor...');
    
    // API key kontrolü
    if (!isApiKeyConfigured) {
      print('🔴 [GEMINI] API key yapılandırılmamış!');
      throw Exception('Gemini API key yapılandırılmamış. Lütfen lib/services/gemini_service.dart dosyasına API key ekleyin.');
    }
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'Sen bir YKS (Yükseköğretim Kurumları Sınavı) asistanısın. '
        'Türkiye\'deki öğrencilere TYT, AYT ve YDT sınavlarına hazırlanırken yardımcı oluyorsun. '
        'Öğrencilere çalışma programı oluşturma, konu anlatımı, soru çözümü ve motivasyon konularında destek veriyorsun. '
        'Türkçe konuş ve arkadaşça, motive edici bir ton kullan. '
        'Cevaplarını net, anlaşılır ve öğretici tut. '
        'Matematik, Fizik, Kimya, Biyoloji, Türkçe, Edebiyat, Tarih, Coğrafya ve Felsefe derslerinde uzman gibi davran.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
    
    _chat = _model.startChat();
    print('✅ [GEMINI] Service başarıyla başlatıldı');
  }

  Future<String> sendMessage(String message) async {
    try {
      // API key kontrolü
      if (!isApiKeyConfigured) {
        return 'API anahtarı yapılandırılmamış. Lütfen uygulama geliştiricisine bildirin.';
      }
      
      print('🤖 [GEMINI] Mesaj gönderiliyor: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);
      
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        print('⚠️ [GEMINI] Boş cevap alındı');
        return 'Üzgünüm, cevap üretemiyorum. Lütfen sorunuzu farklı şekilde sormayı dener misiniz?';
      }
      
      print('✅ [GEMINI] Cevap alındı: ${text.substring(0, text.length > 80 ? 80 : text.length)}...');
      return text;
      
    } on GenerativeAIException catch (e) {
      print('🔴 [GEMINI] AI Exception: ${e.message}');
      
      if (e.message.contains('API key') || e.message.contains('API_KEY_INVALID') || e.message.contains('API key not valid')) {
        return 'API anahtarı geçersiz veya eksik. Lütfen uygulama geliştiricisine bildirin.';
      } else if (e.message.contains('quota')) {
        return 'API kullanım limitine ulaşıldı. Lütfen daha sonra tekrar deneyin.';
      } else if (e.message.contains('safety')) {
        return 'Üzgünüm, bu mesaj güvenlik politikalarına aykırı. Lütfen farklı bir şekilde sorun.';
      }
      
      return 'Bir hata oluştu: ${e.message}';
      
    } catch (e) {
      print('🔴 [GEMINI] Genel Hata: $e');
      return 'Üzgünüm, şu anda bir sorun yaşıyorum. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';
    }
  }

  Future<String> sendMessageWithImage(String message, Uint8List imageBytes) async {
    try {
      // API key kontrolü
      if (!isApiKeyConfigured) {
        return 'API anahtarı yapılandırılmamış. Lütfen uygulama geliştiricisine bildirin.';
      }
      
      print('📸 [GEMINI] Görsel ile mesaj gönderiliyor...');
      print('📸 [GEMINI] Görsel boyutu: ${imageBytes.length} bytes');
      
      final content = Content.multi([
        TextPart(message),
        DataPart('image/jpeg', imageBytes),
      ]);
      
      final response = await _chat.sendMessage(content);
      
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        print('⚠️ [GEMINI] Boş cevap alındı');
        return 'Üzgünüm, görseli analiz edemedim. Lütfen daha net bir fotoğraf çekmeyi dener misiniz?';
      }
      
      print('✅ [GEMINI] Görsel başarıyla analiz edildi');
      print('✅ [GEMINI] Cevap uzunluğu: ${text.length} karakter');
      return text;
      
    } on GenerativeAIException catch (e) {
      print('🔴 [GEMINI] Görsel AI Exception: ${e.message}');
      
      if (e.message.contains('API key') || e.message.contains('API_KEY_INVALID') || e.message.contains('API key not valid')) {
        return 'API anahtarı geçersiz veya eksik. Lütfen uygulama geliştiricisine bildirin.';
      } else if (e.message.contains('quota')) {
        return 'API kullanım limitine ulaşıldı. Lütfen daha sonra tekrar deneyin.';
      } else if (e.message.contains('safety')) {
        return 'Üzgünüm, bu görsel güvenlik politikalarına aykırı. Lütfen başka bir görsel deneyin.';
      } else if (e.message.contains('INVALID_ARGUMENT')) {
        return 'Görsel formatı desteklenmiyor. Lütfen JPEG veya PNG formatında bir görsel deneyin.';
      }
      
      return 'Görsel analiz hatası: ${e.message}';
      
    } catch (e) {
      print('🔴 [GEMINI] Görsel Genel Hata: $e');
      return 'Üzgünüm, görseli işlerken bir sorun oluştu. Lütfen tekrar dener misiniz?';
    }
  }

  void resetChat() {
    _chat = _model.startChat();
    print('🔄 [GEMINI] Chat sıfırlandı');
  }
  
  void dispose() {
    // Cleanup if needed
    print('👋 [GEMINI] Service kapatıldı');
  }
}

