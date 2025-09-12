// lib/features/papers/presentation/providers/papers_presentation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/papers_controller.dart';

final papersControllerProvider = StateNotifierProvider<PapersController, PapersState>((ref) {
  return PapersController(ref);
});