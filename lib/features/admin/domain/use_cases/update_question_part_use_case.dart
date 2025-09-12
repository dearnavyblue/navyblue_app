// lib/features/admin/domain/use_cases/update_question_part_use_case.dart
import '../../../../brick/models/question_part.model.dart';
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class UpdateQuestionPartUseCase {
  final AdminRepository _repository;

  UpdateQuestionPartUseCase(this._repository);

  Future<AdminResult<QuestionPart>> call(String partId, Map<String, dynamic> updateData) async {
    return await _repository.updateQuestionPart(partId, updateData);
  }
}