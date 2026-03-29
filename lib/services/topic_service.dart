import 'api_service.dart';

class TopicService {
  final ApiService _api = ApiService();
  
  // Tamamlanan konuları getir
  Future<Set<String>> getCompletedTopics() async {
    final result = await _api.get('get_topic_progress.php');
    
    if (result['success'] == true && result['completedTopics'] != null) {
      final List<dynamic> topics = result['completedTopics'];
      return topics.map((topic) {
        final examType = topic['exam_type'] as String;
        final subject = topic['subject'] as String;
        final topicName = topic['topic'] as String;
        return '$examType|$subject|$topicName';
      }).toSet();
    }
    
    return {};
  }
  
  // Konu tamamlama durumunu değiştir
  Future<bool> toggleTopic({
    required String examType,
    required String subject,
    required String topic,
    required bool completed,
  }) async {
    final result = await _api.post('toggle_topic.php', {
      'exam_type': examType,
      'subject': subject,
      'topic': topic,
      'completed': completed,
    });
    
    return result['success'] == true;
  }
}

