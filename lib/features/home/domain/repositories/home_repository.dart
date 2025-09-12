// lib/features/home/domain/repositories/home_repository.dart
import '../entities/home_result.dart';
import '../entities/progress_summary.dart';

abstract class HomeRepository {
  Future<HomeResult<ProgressSummary>> getProgressSummary();
}