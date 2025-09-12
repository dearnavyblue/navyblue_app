// lib/features/attempts/data/repositories/attempts_repository_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:navyblue_app/features/attempts/domain/entities/user_attempts_response.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/repositories/attempts_repository.dart';
import '../../domain/entities/attempt_result.dart';
import '../../domain/entities/attempt_config.dart';
import '../../domain/entities/attempt_response.dart';
import '../../domain/entities/step_marking_response.dart';
import '../../domain/entities/attempt_progress.dart';
import '../../../../brick/models/student_attempt.model.dart';

class AttemptsRepositoryImpl implements AttemptsRepository {
  final http.Client _httpClient;
  final String? _accessToken;

  AttemptsRepositoryImpl({
    required http.Client httpClient,
    String? accessToken,
  })  : _httpClient = httpClient,
        _accessToken = accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  @override
  Future<AttemptResult<AttemptResponse>> createAttempt(
      AttemptConfig config) async {
    try {
      final body = jsonEncode({
        'paperId': config.paperId,
        'mode': config.mode,
        'enableHints': config.enableHints,
      });

      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/attempts'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final attemptResponse = AttemptResponse.fromJson(data);
        return AttemptResult.success(attemptResponse);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(
            error['message'] ?? 'Failed to create attempt');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AttemptResult<UserAttemptsResponse>> getUserAttempts({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/attempts')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userAttemptsResponse = UserAttemptsResponse.fromJson(data);
        return AttemptResult.success(userAttemptsResponse);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(
            error['message'] ?? 'Failed to get attempts');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AttemptResult<StudentAttempt>> getAttempt(String attemptId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/attempts/$attemptId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attempt = StudentAttempt.fromJson(data);
        return AttemptResult.success(attempt);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(
            error['message'] ?? 'Failed to get attempt');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AttemptResult<StepMarkingResponse>> markStep({
    required String attemptId,
    required String stepId,
    required String status,
  }) async {
    try {
      final body = jsonEncode({
        'stepId': stepId,
        'status': status,
      });

      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/attempts/$attemptId/mark-step'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final markingResponse = StepMarkingResponse.fromJson(data);
        return AttemptResult.success(markingResponse);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(error['message'] ?? 'Failed to mark step');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AttemptResult<AttemptProgress>> getAttemptProgress(
      String attemptId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/attempts/$attemptId/progress'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progress = AttemptProgress.fromJson(data);
        return AttemptResult.success(progress);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(
            error['message'] ?? 'Failed to get progress');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AttemptResult<StudentAttempt>> completeAttempt({
    required String attemptId,
    bool autoSubmitted = false,
  }) async {
    try {
      final body = jsonEncode({
        'autoSubmitted': autoSubmitted,
      });

      final response = await _httpClient.put(
        Uri.parse('${AppConfig.apiBaseUrl}/attempts/$attemptId/complete'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attempt = StudentAttempt.fromJson(data);
        return AttemptResult.success(attempt);
      } else {
        final error = jsonDecode(response.body);
        return AttemptResult.failure(
            error['message'] ?? 'Failed to complete attempt');
      }
    } catch (e) {
      return AttemptResult.failure('Network error: ${e.toString()}');
    }
  }
}
