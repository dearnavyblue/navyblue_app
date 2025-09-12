// lib/features/admin/domain/use_cases/delete_question_use_case.dart
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class DeleteQuestionUseCase {
  final AdminRepository _repository;

  DeleteQuestionUseCase(this._repository);

  Future<AdminResult<void>> call(String questionId) async {
    return await _repository.deleteQuestion(questionId);
  }
}