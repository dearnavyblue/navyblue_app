// lib/features/attempts/domain/use_cases/get_attempt_use_case.dart
import '../entities/attempt_result.dart';
import '../repositories/attempts_repository.dart';
import '../../../../brick/models/student_attempt.model.dart';

class GetAttemptUseCase {
  final AttemptsRepository _repository;

  GetAttemptUseCase(this._repository);

  Future<AttemptResult<StudentAttempt>> call(String attemptId) async {
    return await _repository.getAttempt(attemptId);
  }
}