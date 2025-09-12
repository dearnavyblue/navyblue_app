// lib/features/admin/domain/providers/admin_use_case_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/add_questions_to_paper_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/create_direct_solution_step_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/get_paper_questions_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/delete_question_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/create_question_part_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/update_question_part_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/delete_question_part_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/create_solution_step_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/update_solution_step_use_case.dart';
import 'package:navyblue_app/features/admin/domain/use_cases/delete_solution_step_use_case.dart';
import '../../data/providers/admin_data_providers.dart';
import '../use_cases/create_paper_use_case.dart';
import '../use_cases/get_papers_use_case.dart';
import '../use_cases/update_paper_status_use_case.dart';
import '../use_cases/delete_paper_use_case.dart';
import '../use_cases/get_users_use_case.dart';
import '../use_cases/update_user_use_case.dart';
import '../use_cases/upload_image_use_case.dart';

// Existing providers
final createPaperUseCaseProvider = Provider<CreatePaperUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return CreatePaperUseCase(repository);
});

final getPapersUseCaseProvider = Provider<GetPapersUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetPapersUseCase(repository);
});

final updatePaperStatusUseCaseProvider =
    Provider<UpdatePaperStatusUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdatePaperStatusUseCase(repository);
});

final deletePaperUseCaseProvider = Provider<DeletePaperUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeletePaperUseCase(repository);
});

final addQuestionsToPaperUseCaseProvider =
    Provider<AddQuestionsToPaperUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AddQuestionsToPaperUseCase(repository);
});

final getPaperQuestionsUseCaseProvider =
    Provider<GetPaperQuestionsUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetPaperQuestionsUseCase(repository);
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return GetUsersUseCase(repository);
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateUserUseCase(repository);
});

final uploadImageUseCaseProvider = Provider<UploadImageUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UploadImageUseCase(repository);
});

// NEW: Question CRUD providers
final deleteQuestionUseCaseProvider = Provider<DeleteQuestionUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteQuestionUseCase(repository);
});

// NEW: Question Part CRUD providers
final createQuestionPartUseCaseProvider =
    Provider<CreateQuestionPartUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return CreateQuestionPartUseCase(repository);
});

final updateQuestionPartUseCaseProvider =
    Provider<UpdateQuestionPartUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateQuestionPartUseCase(repository);
});

final deleteQuestionPartUseCaseProvider =
    Provider<DeleteQuestionPartUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteQuestionPartUseCase(repository);
});

// NEW: Solution Step CRUD providers
final createSolutionStepUseCaseProvider =
    Provider<CreateSolutionStepUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return CreateSolutionStepUseCase(repository);
});

final updateSolutionStepUseCaseProvider =
    Provider<UpdateSolutionStepUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UpdateSolutionStepUseCase(repository);
});

final deleteSolutionStepUseCaseProvider =
    Provider<DeleteSolutionStepUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return DeleteSolutionStepUseCase(repository);
});

final createDirectSolutionStepUseCaseProvider =
    Provider<CreateDirectSolutionStepUseCase>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return CreateDirectSolutionStepUseCase(repository);
});
