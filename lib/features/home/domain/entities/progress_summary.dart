// lib/features/home/domain/entities/progress_summary.dart

import 'package:navyblue_app/features/home/domain/entities/subject_progress.dart';

class ProgressSummary {
  final Map<String, SubjectProgress> subjects;
  final bool hasData;
  final DateTime? lastUpdated;

  const ProgressSummary({
    required this.subjects,
    required this.hasData,
    this.lastUpdated,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    final subjects = <String, SubjectProgress>{};

    // Remove hasData and lastUpdated from the map before processing subjects
    final subjectsData = Map<String, dynamic>.from(json);
    subjectsData.remove('hasData');
    subjectsData.remove('lastUpdated');

    for (final entry in subjectsData.entries) {
      subjects[entry.key] = SubjectProgress.fromJson(entry.value);
    }

    return ProgressSummary(
      subjects: subjects,
      hasData: json['hasData'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}
