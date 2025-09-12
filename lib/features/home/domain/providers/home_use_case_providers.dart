// lib/features/home/domain/providers/home_use_case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/get_progress_summary_use_case.dart';
import '../../data/providers/home_data_providers.dart';

final getProgressSummaryUseCaseProvider = Provider<GetProgressSummaryUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetProgressSummaryUseCase(repository);
});
