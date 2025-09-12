// lib/features/auth/presentation/providers/auth_presentation_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navyblue_app/brick/models/user.model.dart';
import '../controllers/auth_controller.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) => ref.watch(authControllerProvider).user);
final isLoggedInProvider = Provider<bool>((ref) => ref.watch(authControllerProvider).isLoggedIn);
final isAdminProvider = Provider<bool>((ref) => ref.watch(authControllerProvider).isAdmin);