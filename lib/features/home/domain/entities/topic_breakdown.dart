// lib/features/home/domain/entities/topic_breakdown.dart
class TopicBreakdown {
  final String topic;
  final double overallAccuracy;
  final int totalAttempted;
  final int totalCorrect;
  final int totalMarksEarned;
  final String status;
  final List<SubTopic>? subTopics;

  const TopicBreakdown({
    required this.topic,
    required this.overallAccuracy,
    required this.totalAttempted,
    required this.totalCorrect,
    required this.totalMarksEarned,
    required this.status,
    this.subTopics,
  });

  factory TopicBreakdown.fromJson(Map<String, dynamic> json) {
    return TopicBreakdown(
      topic: json['topic'] ?? '',
      overallAccuracy: (json['overallAccuracy'] ?? 0).toDouble(),
      totalAttempted: json['totalAttempted'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalMarksEarned: json['totalMarksEarned'] ?? 0,
      status: json['status'] ?? '',
      subTopics: json['subTopics'] != null
          ? (json['subTopics'] as List)
              .map((st) => SubTopic.fromJson(st))
              .toList()
          : null,
    );
  }
}

class SubTopic {
  final String name;
  final double accuracy;
  final int attempted;
  final int correct;
  final int marksEarned;
  final String status;

  const SubTopic({
    required this.name,
    required this.accuracy,
    required this.attempted,
    required this.correct,
    required this.marksEarned,
    required this.status,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    return SubTopic(
      name: json['name'] ?? '',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      attempted: json['attempted'] ?? 0,
      correct: json['correct'] ?? 0,
      marksEarned: json['marksEarned'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
