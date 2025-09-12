// lib/features/admin/domain/use_cases/delete_solution_step_use_case.dart
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class DeleteSolutionStepUseCase {
  final AdminRepository _repository;

  DeleteSolutionStepUseCase(this._repository);

  Future<AdminResult<void>> call(String stepId) async {
    return await _repository.deleteSolutionStep(stepId);
  }
}