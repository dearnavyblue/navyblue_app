// lib/features/home/domain/entities/topic_breakdown.dart
class TopicBreakdown {
  final String topic;
  final double score;
  final int attempts;

  const TopicBreakdown({
    required this.topic,
    required this.score,
    required this.attempts,
  });

  factory TopicBreakdown.fromJson(Map<String, dynamic> json) {
    return TopicBreakdown(
      topic: json['topic'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      attempts: json['attempts'] ?? 0,
    );
  }
}