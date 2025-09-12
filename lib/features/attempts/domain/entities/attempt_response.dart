import '../../../../brick/models/student_attempt.model.dart';

class AttemptResponse {
  final StudentAttempt attempt;
  final String message;

  const AttemptResponse({
    required this.attempt,
    required this.message,
  });

  factory AttemptResponse.fromJson(Map<String, dynamic> json) {
    // Handle direct attempt object (your current backend response)
    if (json.containsKey('id') && json.containsKey('paperId')) {
      return AttemptResponse(
        attempt: StudentAttempt.fromJson(json),
        message: 'Attempt created successfully',
      );
    }
    
    // Handle wrapped response format
    return AttemptResponse(
      attempt: StudentAttempt.fromJson(json['attempt']),
      message: json['message'] ?? 'Attempt created successfully',
    );
  }
}
