// lib/features/papers/domain/providers/papers_use_case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/papers_data_providers.dart';
import '../use_cases/get_papers_use_case.dart';
import '../use_cases/get_paper_use_case.dart';
import '../use_cases/get_paper_page_use_case.dart';
import '../use_cases/search_papers_use_case.dart';
import '../use_cases/get_filter_options_use_case.dart';

final getPapersUseCaseProvider = Provider<GetPapersUseCase>((ref) {
  final repository = ref.watch(papersRepositoryProvider);
  return GetPapersUseCase(repository);
});

final getPaperUseCaseProvider = Provider<GetPaperUseCase>((ref) {
  final repository = ref.watch(papersRepositoryProvider);
  return GetPaperUseCase(repository);
});

final getPaperPageUseCaseProvider = Provider<GetPaperPageUseCase>((ref) {
  final repository = ref.watch(papersRepositoryProvider);
  return GetPaperPageUseCase(repository);
});

final searchPapersUseCaseProvider = Provider<SearchPapersUseCase>((ref) {
  final repository = ref.watch(papersRepositoryProvider);
  return SearchPapersUseCase(repository);
});

final getFilterOptionsUseCaseProvider = Provider<GetFilterOptionsUseCase>((ref) {
  final repository = ref.watch(papersRepositoryProvider);
  return GetFilterOptionsUseCase(repository);
});
