// lib/features/auth/domain/use_cases/login_use_case.dart
import 'package:flutter/foundation.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResult> call({
    required String email,
    required String password,
  }) async {
    // Input validation
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }

    // Attempt login
    final result = await _repository.login(
      email: email.trim(),
      password: password,
    );

    // Business rule: Admin access restricted to web only
    if (result.isSuccess && result.user!.isAdmin && !kIsWeb) {
      await _repository.logout();
      return AuthResult.failure('Admin access is only available on web');
    }

    return result;
  }
}