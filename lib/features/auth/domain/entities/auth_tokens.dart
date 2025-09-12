// lib/features/auth/domain/entities/auth_tokens.dart
class AuthTokens {
  final Token access;
  final Token refresh;

  const AuthTokens({
    required this.access,
    required this.refresh,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      access: Token.fromJson(json['access']),
      refresh: Token.fromJson(json['refresh']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access.toJson(),
      'refresh': refresh.toJson(),
    };
  }

  Token? get validToken => access.isExpired ? null : access;
  bool get isAccessExpired => access.isExpired;
  bool get isRefreshExpired => refresh.isExpired;
  bool get areTokensValid => !access.isExpired && !refresh.isExpired;
}

class Token {
  final String token;
  final DateTime expires;

  const Token({
    required this.token,
    required this.expires,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'],
      expires: DateTime.parse(json['expires']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires': expires.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expires);
  bool get isValid => !isExpired;
}