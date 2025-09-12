// lib/features/home/domain/use_cases/get_progress_summary_use_case.dart
import '../entities/home_result.dart';
import '../entities/progress_summary.dart';
import '../repositories/home_repository.dart';

class GetProgressSummaryUseCase {
  final HomeRepository _repository;

  GetProgressSummaryUseCase(this._repository);

  Future<HomeResult<ProgressSummary>> call() async {
    return await _repository.getProgressSummary();
  }
}