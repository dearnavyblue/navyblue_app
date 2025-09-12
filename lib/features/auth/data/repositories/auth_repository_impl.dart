// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../brick/models/user.model.dart';
import '../../../../brick/repository.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client _httpClient;
  final Repository _repository;

  AuthRepositoryImpl({
    required http.Client httpClient,
    required Repository repository,
  })  : _httpClient = httpClient,
        _repository = repository;

  User? _currentUser;

  @override
  User? getCurrentUser() => _currentUser;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = AuthTokens.fromJson(data['tokens']);

        final user = User(
          id: data['user']['id'],
          email: data['user']['email'],
          firstName: data['user']['firstName'],
          lastName: data['user']['lastName'],
          grade: data['user']['grade'],
          province: data['user']['province'],
          syllabus: data['user']['syllabus'],
          schoolName: data['user']['schoolName'],
          role: data['user']['role'] ?? 'USER',
          isEmailVerified: data['user']['isEmailVerified'] ?? false,
          createdAt: DateTime.parse(data['user']['createdAt']),
          accessToken: tokens.access.token,
          refreshToken: tokens.refresh.token,
          tokenExpiresAt: tokens.access.expires,
          lastLoginAt: DateTime.now(),
        );

        await _repository.upsert<User>(user);
        _currentUser = user;

        return AuthResult.success(user: user, tokens: tokens);
      } else {
        final error = jsonDecode(response.body);
        return AuthResult.failure(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String grade,
    required String province,
    required String syllabus,
    String? schoolName,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'grade': grade,
          'province': province,
          'syllabus': syllabus,
          'schoolName': schoolName,
          'role': 'USER',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final tokens = AuthTokens.fromJson(data['tokens']);

        final user = User(
          id: data['user']['id'],
          email: data['user']['email'],
          firstName: data['user']['firstName'],
          lastName: data['user']['lastName'],
          grade: data['user']['grade'],
          province: data['user']['province'],
          syllabus: data['user']['syllabus'],
          schoolName: data['user']['schoolName'],
          role: data['user']['role'] ?? 'USER',
          isEmailVerified: data['user']['isEmailVerified'] ?? false,
          createdAt: DateTime.parse(data['user']['createdAt']),
          accessToken: tokens.access.token,
          refreshToken: tokens.refresh.token,
          tokenExpiresAt: tokens.access.expires,
          lastLoginAt: DateTime.now(),
        );

        await _repository.upsert<User>(user);
        _currentUser = user;

        return AuthResult.success(user: user, tokens: tokens);
      } else {
        final error = jsonDecode(response.body);
        return AuthResult.failure(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    print('Repository logout starting...');

    // Try server logout but continue regardless of result
    if (_currentUser?.refreshToken != null) {
      try {
        print(
            'Attempting server logout with token: ${_currentUser!.refreshToken!.substring(0, 20)}...');

        final response = await _httpClient.post(
          Uri.parse('${AppConfig.apiBaseUrl}/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': _currentUser!.refreshToken!}),
        );

        if (response.statusCode == 204) {
          print('✅ Server logout successful');
        } else {
          print(
              '⚠️ Server logout failed: ${response.statusCode} - This is OK, token was likely already invalid');
        }
      } catch (e) {
        print(
            '⚠️ Server logout request failed: $e - This is OK, continuing with local logout');
      }
    } else {
      print('No refresh token available for server logout');
    }

    // ALWAYS clear local tokens
    try {
      if (_currentUser != null) {
        final clearedUser = _currentUser!.clearAuthTokens();

        await _repository.upsert<User>(clearedUser);
        _currentUser = clearedUser;

        print('✅ Repository: Local tokens cleared successfully');
        print('User isTokenValid: ${_currentUser!.isTokenValid}');
      } else {
        print('No current user to clear');
      }
    } catch (e) {
      print('❌ Failed to clear tokens in repository: $e');
      _currentUser = null;
    }

    print('Repository logout completed');
  }

  Future<void> _clearAuthTokensOnly() async {
    try {
      if (_currentUser != null) {
        final userWithoutTokens = _currentUser!.copyWith(
          accessToken: null,
          refreshToken: null,
          tokenExpiresAt: null,
          lastLoginAt: null,
        );
        await _repository.upsert<User>(userWithoutTokens);
        _currentUser = userWithoutTokens;
        print('Local auth tokens cleared successfully');
      }
    } catch (e) {
      print('Failed to clear auth tokens in repository: $e');
      // Set to null as fallback
      _currentUser = null;
    }
  }

  @override
  Future<bool> refreshTokens() async {
    if (_currentUser?.refreshToken == null) return false;

    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh-tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _currentUser!.refreshToken!}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokens = AuthTokens.fromJson(data);

        final updatedUser = _currentUser!.copyWith(
          accessToken: tokens.access.token,
          refreshToken: tokens.refresh.token,
          tokenExpiresAt: tokens.access.expires,
        );

        await _repository.upsert<User>(updatedUser);
        _currentUser = updatedUser;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/reset-password?token=$token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sendVerificationEmail() async {
    if (_currentUser?.accessToken == null) return false;
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/send-verification-email'),
        headers: {'Authorization': 'Bearer ${_currentUser!.accessToken!}'},
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> verifyEmail(String token) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/verify-email?token=$token'),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> initializeUser() async {
    await _loadUserFromBrick();
  }

  @override
  String? get accessToken => _currentUser?.accessToken;

  @override
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> _loadUserFromBrick() async {
    try {
      final users = await _repository.get<User>();
      if (users.isNotEmpty) {
        _currentUser = users.first;

        if (_currentUser != null && !_currentUser!.isTokenValid) {
          final refreshed = await refreshTokens();
          if (!refreshed) {
            await logout();
          }
        }
      }
    } catch (_) {
      _currentUser = null;
    }
  }
}
