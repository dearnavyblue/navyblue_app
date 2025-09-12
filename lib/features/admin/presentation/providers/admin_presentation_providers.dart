// lib/features/admin/presentation/providers/admin_presentation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/user.model.dart';
import '../controllers/admin_controller.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController(ref);
});

// Convenience providers
final adminPapersProvider = Provider<List<ExamPaper>>(
    (ref) => ref.watch(adminControllerProvider).papers);

final adminUsersProvider =
    Provider<List<User>>((ref) => ref.watch(adminControllerProvider).users);

final adminIsLoadingProvider =
    Provider<bool>((ref) => ref.watch(adminControllerProvider).isLoading);

final adminCurrentPaperJsonProvider = Provider<Map<String, dynamic>?>(
    (ref) => ref.watch(adminControllerProvider).currentPaperJson);

final adminImageUploadsProvider = Provider<Map<String, String>>(
    (ref) => ref.watch(adminControllerProvider).imageUploads);

final adminErrorProvider =
    Provider<String?>((ref) => ref.watch(adminControllerProvider).error);

// Helper providers for UI state
final adminHasPaperDataProvider = Provider<bool>((ref) {
  final currentPaper = ref.watch(adminCurrentPaperJsonProvider);
  return currentPaper != null;
});

final adminImageUploadPathsProvider = Provider<List<String>>((ref) {
  final controller = ref.read(adminControllerProvider.notifier);
  return controller.getImageUploadPaths();
});

final adminPendingImageUploadsProvider = Provider<int>((ref) {
  final imagePaths = ref.watch(adminImageUploadPathsProvider);
  final imageUploads = ref.watch(adminImageUploadsProvider);
  return imagePaths.where((path) => !imageUploads.containsKey(path)).length;
});

final adminCanSubmitPaperProvider = Provider<bool>((ref) {
  final hasPaperData = ref.watch(adminHasPaperDataProvider);
  final isLoading = ref.watch(adminIsLoadingProvider);
  final pendingUploads = ref.watch(adminPendingImageUploadsProvider);

  return hasPaperData && !isLoading && pendingUploads == 0;
});
