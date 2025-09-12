// lib/features/admin/domain/use_cases/get_paper_questions_use_case.dart
import 'package:navyblue_app/brick/models/question.model.dart';
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class GetPaperQuestionsUseCase {
  final AdminRepository _repository;

  GetPaperQuestionsUseCase(this._repository);

  Future<AdminResult<List<Question>>> call(String paperId) async {
    return await _repository.getPaperQuestions(paperId);
  }
}