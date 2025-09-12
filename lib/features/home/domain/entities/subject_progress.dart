// lib/features/home/domain/entities/subject_progress.dart
import 'package:navyblue_app/features/home/domain/entities/performance_data.dart';

class SubjectProgress {
  final int overallReadiness;
  final String readinessLevel;
  final PerformanceData practicePerformance;
  final PerformanceData examPerformance;

  const SubjectProgress({
    required this.overallReadiness,
    required this.readinessLevel,
    required this.practicePerformance,
    required this.examPerformance,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      overallReadiness: json['overallReadiness'] ?? 0,
      readinessLevel: json['readinessLevel'] ?? 'Unknown',
      practicePerformance: PerformanceData.fromJson(
        json['practicePerformance'] ?? {}),
      examPerformance: PerformanceData.fromJson(
        json['examPerformance'] ?? {}),
    );
  }
}
