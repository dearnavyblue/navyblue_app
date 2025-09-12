// lib/features/auth/domain/providers/auth_use_case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_data_providers.dart';
import '../use_cases/login_use_case.dart';
import '../use_cases/register_use_case.dart';
import '../use_cases/logout_use_case.dart';
import '../use_cases/get_current_user_use_case.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});