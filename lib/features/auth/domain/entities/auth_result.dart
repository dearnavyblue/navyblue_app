// lib/features/auth/domain/entities/auth_result.dart
import 'package:navyblue_app/brick/models/user.model.dart';

import 'auth_tokens.dart';

class AuthResult {
  final bool isSuccess;
  final User? user;
  final AuthTokens? tokens;
  final String? error;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.tokens,
    this.error,
  });

  factory AuthResult.success({
    required User user,
    required AuthTokens tokens,
  }) {
    return AuthResult._(isSuccess: true, user: user, tokens: tokens);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
