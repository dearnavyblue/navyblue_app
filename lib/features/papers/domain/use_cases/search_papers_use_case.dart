// lib/features/papers/domain/use_cases/search_papers_use_case.dart
import '../entities/papers_response.dart';
import '../entities/paper_result.dart';
import '../repositories/papers_repository.dart';

class SearchPapersUseCase {
  final PapersRepository _repository;

  SearchPapersUseCase(this._repository);

  Future<PaperResult<PapersResponse>> call({
    required String query,
    int? page,
    int? limit,
  }) async {
    return await _repository.searchPapers(
      query: query,
      page: page,
      limit: limit,
    );
  }
}
