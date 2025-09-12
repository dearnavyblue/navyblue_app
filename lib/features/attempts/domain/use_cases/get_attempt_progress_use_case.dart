// lib/features/attempts/domain/use_cases/get_attempt_progress_use_case.dart
import '../entities/attempt_result.dart';
import '../entities/attempt_progress.dart';
import '../repositories/attempts_repository.dart';

class GetAttemptProgressUseCase {
  final AttemptsRepository _repository;

  GetAttemptProgressUseCase(this._repository);

  Future<AttemptResult<AttemptProgress>> call(String attemptId) async {
    return await _repository.getAttemptProgress(attemptId);
  }
}