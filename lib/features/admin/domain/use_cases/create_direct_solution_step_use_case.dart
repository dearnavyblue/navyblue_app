import 'package:navyblue_app/brick/models/solution_step.model.dart';

import '../../domain/entities/admin_result.dart';
import '../../domain/repositories/admin_repository.dart';

class CreateDirectSolutionStepUseCase {
  final AdminRepository _repository;

  CreateDirectSolutionStepUseCase(this._repository);

  Future<AdminResult<SolutionStep>> call(
      String questionId, Map<String, dynamic> stepData) {
    return _repository.createDirectSolutionStep(questionId, stepData);
  }
}