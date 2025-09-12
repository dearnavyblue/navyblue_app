// lib/features/attempts/domain/entities/attempt_progress.dart
class AttemptProgress {
  final String attemptId;
  final int totalSteps;
  final int markedSteps;
  final int correctSteps;
  final int totalMarksEarned;
  final int totalMarksPossible;
  final double percentageScore;

  const AttemptProgress({
    required this.attemptId,
    required this.totalSteps,
    required this.markedSteps,
    required this.correctSteps,
    required this.totalMarksEarned,
    required this.totalMarksPossible,
    required this.percentageScore,
  });

  factory AttemptProgress.fromJson(Map<String, dynamic> json) {
    return AttemptProgress(
      attemptId: json['attemptId'] ?? '',
      totalSteps: json['progress']?['totalSteps'] ?? 0,
      markedSteps: json['progress']?['markedSteps'] ?? 0,
      correctSteps: json['progress']?['correctSteps'] ?? 0,
      totalMarksEarned: json['scoring']?['marksEarned'] ?? 0,
      totalMarksPossible: json['scoring']?['totalMarksPossible'] ?? 0,
      percentageScore: (json['scoring']?['percentageScore'] ?? 0.0).toDouble(),
    );
  }

  // Helper getters
  int get incorrectSteps => markedSteps - correctSteps;
  int get notAttemptedSteps => totalSteps - markedSteps;
  double get progressPercent =>
      totalSteps > 0 ? (markedSteps / totalSteps) * 100 : 0.0;
  double get accuracyPercent =>
      markedSteps > 0 ? (correctSteps / markedSteps) * 100 : 0.0;
}
