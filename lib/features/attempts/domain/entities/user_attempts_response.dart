// lib/features/attempts/domain/entities/user_attempts_response.dart
import '../../../../brick/models/student_attempt.model.dart';
import '../../../../brick/models/exam_paper.model.dart';

class UserAttemptsResponse {
  final List<StudentAttempt> attempts;
  final Map<String, ExamPaper> papers;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  const UserAttemptsResponse({
    required this.attempts,
    required this.papers,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  factory UserAttemptsResponse.fromJson(Map<String, dynamic> json) {
    final attemptsJsonList = json['attempts'] as List<dynamic>? ?? [];
    final attempts = <StudentAttempt>[];
    final papers = <String, ExamPaper>{};

    for (final attemptJson in attemptsJsonList) {
      // Parse attempt
      final attemptData = Map<String, dynamic>.from(attemptJson);
      attemptData.remove('paper');
      attempts.add(StudentAttempt.fromJson(attemptData));

      // Extract paper
      if (attemptJson['paper'] != null) {
        final paperData = attemptJson['paper'];
        papers[paperData['id']] = ExamPaper.fromJson(paperData);
      }
    }

    return UserAttemptsResponse(
      attempts: attempts,
      papers: papers,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}
