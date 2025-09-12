// lib/features/attempts/domain/use_cases/complete_attempt_use_case.dart
import '../entities/attempt_result.dart';
import '../repositories/attempts_repository.dart';
import '../../../../brick/models/student_attempt.model.dart';

class CompleteAttemptUseCase {
  final AttemptsRepository _repository;

  CompleteAttemptUseCase(this._repository);

  Future<AttemptResult<StudentAttempt>> call({
    required String attemptId,
    bool autoSubmitted = false,
  }) async {
    return await _repository.completeAttempt(
      attemptId: attemptId,
      autoSubmitted: autoSubmitted,
    );
  }
}