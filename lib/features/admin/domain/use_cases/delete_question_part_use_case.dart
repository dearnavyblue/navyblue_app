// lib/features/admin/domain/use_cases/delete_question_part_use_case.dart
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class DeleteQuestionPartUseCase {
  final AdminRepository _repository;

  DeleteQuestionPartUseCase(this._repository);

  Future<AdminResult<void>> call(String partId) async {
    return await _repository.deleteQuestionPart(partId);
  }
}