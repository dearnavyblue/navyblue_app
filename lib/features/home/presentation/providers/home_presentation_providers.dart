// lib/features/home/presentation/providers/home_presentation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_controller.dart';

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});