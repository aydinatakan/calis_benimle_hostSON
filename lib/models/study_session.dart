class StudySession {
  final DateTime date;
  final int durationInSeconds;

  StudySession({
    required this.date,
    required this.durationInSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'durationInSeconds': durationInSeconds,
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      date: DateTime.parse(json['date']),
      durationInSeconds: json['durationInSeconds'],
    );
  }

  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double get hours {
    return durationInSeconds / 3600;
  }
}

