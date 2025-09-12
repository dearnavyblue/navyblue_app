// lib/features/home/domain/entities/performance_data.dart
import 'package:navyblue_app/features/home/domain/entities/topic_breakdown.dart';

class PerformanceData {
  final double averageScore;
  final int attempts;
  final List<TopicBreakdown> topicBreakdown;

  const PerformanceData({
    required this.averageScore,
    required this.attempts,
    required this.topicBreakdown,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      attempts: json['attempts'] ?? 0,
      topicBreakdown: (json['topicBreakdown'] as List<dynamic>? ?? [])
          .map((topic) => TopicBreakdown.fromJson(topic))
          .toList(),
    );
  }
}
