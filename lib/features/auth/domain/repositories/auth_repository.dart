// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:navyblue_app/brick/models/user.model.dart';

import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String grade,
    required String province,
    required String syllabus,
    String? schoolName,
  });

  Future<void> logout();
  Future<bool> refreshTokens();
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword({required String token, required String password});
  Future<bool> sendVerificationEmail();
  Future<bool> verifyEmail(String token);
  User? getCurrentUser(); // Fixed: Remove Future wrapper to match implementation
  Future<void> initializeUser();
  String? get accessToken;
  bool get isAdmin;
}