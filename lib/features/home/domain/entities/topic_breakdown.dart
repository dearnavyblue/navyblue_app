// lib/features/home/domain/entities/topic_breakdown.dart
class TopicBreakdown {
  final String topic;
  final double performance;
  final Map<String, double>? subtopics; // For hierarchical display

  const TopicBreakdown({
    required this.topic,
    required this.performance,
    this.subtopics,
  });

  factory TopicBreakdown.fromJson(Map<String, dynamic> json) {
    final subtopicsData = json['subtopics'] as Map<String, dynamic>?;
    Map<String, double>? subtopics;

    if (subtopicsData != null) {
      subtopics = {};
      for (final entry in subtopicsData.entries) {
        subtopics[entry.key] = (entry.value ?? 0).toDouble();
      }
    }

    return TopicBreakdown(
      topic: json['topic'] ?? '',
      performance: (json['performance'] ?? 0).toDouble(),
      subtopics: subtopics,
    );
  }

  // Helper to get formatted topic name
  String get displayName {
    return topic
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
