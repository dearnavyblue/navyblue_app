// lib/features/papers/domain/use_cases/get_paper_page_use_case.dart
import '../entities/paper_result.dart';
import '../repositories/papers_repository.dart';

class GetPaperPageUseCase {
  final PapersRepository _repository;

  GetPaperPageUseCase(this._repository);

  Future<PaperResult<Map<String, dynamic>>> call(String paperId, int pageNumber, {bool includeSolutions = false}) async {
    return await _repository.getPaperPage(paperId, pageNumber, includeSolutions: includeSolutions);
  }
}