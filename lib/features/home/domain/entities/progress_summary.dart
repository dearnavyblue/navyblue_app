// lib/features/home/domain/entities/progress_summary.dart
import 'package:navyblue_app/features/home/domain/entities/subject_progress.dart';

class ProgressSummary {
  final Map<String, SubjectProgress> subjects;
  final bool hasData;

  const ProgressSummary({
    required this.subjects,
    required this.hasData,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    final subjectsData = json['subjects'] as Map<String, dynamic>? ?? {};
    final subjects = <String, SubjectProgress>{};
    
    for (final entry in subjectsData.entries) {
      subjects[entry.key] = SubjectProgress.fromJson(entry.value);
    }

    return ProgressSummary(
      subjects: subjects,
      hasData: json['hasData'] ?? false,
    );
  }
}