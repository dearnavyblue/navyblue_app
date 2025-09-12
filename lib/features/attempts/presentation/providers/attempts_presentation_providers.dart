// lib/features/attempts/presentation/providers/attempts_presentation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/features/attempts/presentation/controllers/attempts_controller.dart';

final attemptsControllerProvider = StateNotifierProvider.family<AttemptsController, AttemptsState, String>((ref, paperId) {
  return AttemptsController(ref, paperId);
});


final userAttemptsControllerProvider = StateNotifierProvider<AttemptsController, AttemptsState>((ref) {
  return AttemptsController(ref, null); // For user attempts listing
});