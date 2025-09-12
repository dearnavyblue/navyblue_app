// lib/features/admin/domain/use_cases/update_solution_step_use_case.dart
import '../../../../brick/models/solution_step.model.dart';
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class UpdateSolutionStepUseCase {
  final AdminRepository _repository;

  UpdateSolutionStepUseCase(this._repository);

  Future<AdminResult<SolutionStep>> call(String stepId, Map<String, dynamic> updateData) async {
    return await _repository.updateSolutionStep(stepId, updateData);
  }
}