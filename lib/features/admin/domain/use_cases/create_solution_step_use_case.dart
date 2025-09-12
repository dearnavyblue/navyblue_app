// lib/features/admin/domain/use_cases/create_solution_step_use_case.dart
import '../../../../brick/models/solution_step.model.dart';
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class CreateSolutionStepUseCase {
  final AdminRepository _repository;

  CreateSolutionStepUseCase(this._repository);

  Future<AdminResult<SolutionStep>> call(String partId, Map<String, dynamic> stepData) async {
    return await _repository.createSolutionStep(partId, stepData);
  }
}