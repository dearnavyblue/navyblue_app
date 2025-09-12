// lib/features/admin/domain/use_cases/add_questions_to_paper_use_case.dart
import 'package:navyblue_app/brick/models/question.model.dart';

import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class AddQuestionsToPaperUseCase {
  final AdminRepository _repository;

  AddQuestionsToPaperUseCase(this._repository);

  Future<AdminResult<List<Question>>> call(String paperId, List<Map<String, dynamic>> questionsData) async {
    if (paperId.isEmpty) {
      return AdminResult.failure('Paper ID is required');
    }
    if (questionsData.isEmpty) {
      return AdminResult.failure('At least one question is required');
    }

    return await _repository.addQuestionsToPaper(paperId, questionsData);
  }
}