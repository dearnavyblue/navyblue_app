// lib/features/attempts/domain/providers/attempts_use_case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../use_cases/create_attempt_use_case.dart';
import '../use_cases/get_user_attempts_use_case.dart';
import '../use_cases/get_attempt_use_case.dart';
import '../use_cases/mark_step_use_case.dart';
import '../use_cases/get_attempt_progress_use_case.dart';
import '../use_cases/complete_attempt_use_case.dart';
import '../../data/providers/attempts_data_providers.dart';

final createAttemptUseCaseProvider = Provider<CreateAttemptUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return CreateAttemptUseCase(repository);
});

final getUserAttemptsUseCaseProvider = Provider<GetUserAttemptsUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return GetUserAttemptsUseCase(repository);
});

final getAttemptUseCaseProvider = Provider<GetAttemptUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return GetAttemptUseCase(repository);
});

final markStepUseCaseProvider = Provider<MarkStepUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return MarkStepUseCase(repository);
});

final getAttemptProgressUseCaseProvider = Provider<GetAttemptProgressUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return GetAttemptProgressUseCase(repository);
});

final completeAttemptUseCaseProvider = Provider<CompleteAttemptUseCase>((ref) {
  final repository = ref.watch(attemptsRepositoryProvider);
  return CompleteAttemptUseCase(repository);
});