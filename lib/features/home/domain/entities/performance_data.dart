// lib/features/home/domain/entities/performance_data.dart
import 'package:navyblue_app/features/home/domain/entities/topic_breakdown.dart';

class PerformanceData {
  final double averageScore;
  final int attempts;
  final List<TopicBreakdown> topicBreakdown;
  final Map<String, PaperPerformance> papers;

  const PerformanceData({
    required this.averageScore,
    required this.attempts,
    required this.topicBreakdown,
    this.papers = const {},
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    // Parse papers
    final papersData = json['papers'] as Map<String, dynamic>? ?? {};
    final parsedPapers = <String, PaperPerformance>{};

    for (final entry in papersData.entries) {
      parsedPapers[entry.key] = PaperPerformance.fromJson(entry.value);
    }

    return PerformanceData(
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      attempts: json['attempts'] ?? 0,
      topicBreakdown: (json['topicBreakdown'] as List<dynamic>? ?? [])
          .map((topic) => TopicBreakdown.fromJson(topic))
          .toList(),
      papers: parsedPapers,
    );
  }
}

class PaperPerformance {
  final double averageScore;
  final int attempts;
  final DateTime? lastAttempt;

  const PaperPerformance({
    required this.averageScore,
    required this.attempts,
    this.lastAttempt,
  });

  factory PaperPerformance.fromJson(Map<String, dynamic> json) {
    return PaperPerformance(
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      attempts: json['attempts'] ?? 0,
      lastAttempt: json['lastAttempt'] != null
          ? DateTime.parse(json['lastAttempt'])
          : null,
    );
  }
}
