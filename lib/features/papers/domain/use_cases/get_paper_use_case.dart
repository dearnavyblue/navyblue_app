// lib/features/papers/domain/use_cases/get_paper_use_case.dart
import '../../../../brick/models/exam_paper.model.dart';
import '../entities/paper_result.dart';
import '../repositories/papers_repository.dart';

class GetPaperUseCase {
  final PapersRepository _repository;

  GetPaperUseCase(this._repository);

  Future<PaperResult<ExamPaper>> call(String paperId, {bool includeSolutions = false}) async {
    return await _repository.getPaper(paperId, includeSolutions: includeSolutions);
  }
}