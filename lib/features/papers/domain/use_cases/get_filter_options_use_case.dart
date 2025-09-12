// lib/features/papers/domain/use_cases/get_filter_options_use_case.dart
import '../entities/paper_filters.dart';
import '../entities/paper_result.dart';
import '../repositories/papers_repository.dart';

class GetFilterOptionsUseCase {
  final PapersRepository _repository;

  GetFilterOptionsUseCase(this._repository);

  Future<PaperResult<PaperFilters>> call() async {
    return await _repository.getFilterOptions();
  }
}