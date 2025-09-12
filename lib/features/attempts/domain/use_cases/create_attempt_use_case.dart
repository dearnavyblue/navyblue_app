// lib/features/attempts/domain/use_cases/create_attempt_use_case.dart
import '../entities/attempt_result.dart';
import '../entities/attempt_config.dart';
import '../entities/attempt_response.dart';
import '../repositories/attempts_repository.dart';

class CreateAttemptUseCase {
  final AttemptsRepository _repository;

  CreateAttemptUseCase(this._repository);

  Future<AttemptResult<AttemptResponse>> call(AttemptConfig config) async {
    return await _repository.createAttempt(config);
  }
}