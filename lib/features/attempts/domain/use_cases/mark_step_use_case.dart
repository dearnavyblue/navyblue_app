// lib/features/attempts/domain/use_cases/mark_step_use_case.dart
import '../entities/attempt_result.dart';
import '../entities/step_marking_response.dart';
import '../repositories/attempts_repository.dart';

class MarkStepUseCase {
  final AttemptsRepository _repository;

  MarkStepUseCase(this._repository);

  Future<AttemptResult<StepMarkingResponse>> call({
    required String attemptId,
    required String stepId,
    required String status,
  }) async {
    return await _repository.markStep(
      attemptId: attemptId,
      stepId: stepId,
      status: status,
    );
  }
}
