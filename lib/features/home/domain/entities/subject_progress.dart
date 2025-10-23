// lib/features/home/domain/entities/subject_progress.dart
class SubjectProgress {
  final Map<String, PaperProgress> papers;

  const SubjectProgress({
    required this.papers,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    final papers = <String, PaperProgress>{};

    for (final entry in json.entries) {
      papers[entry.key] = PaperProgress.fromJson(entry.value);
    }

    return SubjectProgress(papers: papers);
  }
}

class PaperProgress {
  final double averageScore;
  final int totalAttempts;
  final Map<String, TopicProgress> topics;

  const PaperProgress({
    required this.averageScore,
    required this.totalAttempts,
    required this.topics,
  });

  factory PaperProgress.fromJson(Map<String, dynamic> json) {
    final topicsData = json['topics'] as Map<String, dynamic>? ?? {};
    final topics = <String, TopicProgress>{};

    for (final entry in topicsData.entries) {
      topics[entry.key] = TopicProgress.fromJson(entry.value);
    }

    return PaperProgress(
      averageScore: (json['averageScore'] ?? 0).toDouble(),
      totalAttempts: json['totalAttempts'] ?? 0,
      topics: topics,
    );
  }
}

class TopicProgress {
  final double performance;
  final Map<String, double> breakdown; // subtopic path -> performance %

  const TopicProgress({
    required this.performance,
    required this.breakdown,
  });

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    final breakdownData = json['breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <String, double>{};

    for (final entry in breakdownData.entries) {
      breakdown[entry.key] = (entry.value ?? 0).toDouble();
    }

    return TopicProgress(
      performance: (json['performance'] ?? 0).toDouble(),
      breakdown: breakdown,
    );
  }
}
