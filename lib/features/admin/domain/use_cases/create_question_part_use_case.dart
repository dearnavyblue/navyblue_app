// lib/features/admin/domain/use_cases/create_question_part_use_case.dart
import '../../../../brick/models/question_part.model.dart';
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class CreateQuestionPartUseCase {
  final AdminRepository _repository;

  CreateQuestionPartUseCase(this._repository);

  Future<AdminResult<QuestionPart>> call(String questionId, Map<String, dynamic> partData) async {
    return await _repository.createQuestionPart(questionId, partData);
  }
}