// lib/features/auth/domain/use_cases/register_use_case.dart
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<AuthResult> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String grade,
    required String province,
    required String syllabus,
    String? schoolName,
  }) async {
    // Input validation
    if (firstName.trim().isEmpty) {
      return AuthResult.failure('First name is required');
    }
    if (lastName.trim().isEmpty) {
      return AuthResult.failure('Last name is required');
    }
    if (email.trim().isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }

    // Business rule: Registration creates USER role only
    final result = await _repository.register(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      password: password,
      grade: grade,
      province: province,
      syllabus: syllabus,
      schoolName: schoolName?.trim(),
    );

    return result;
  }
}