// lib/features/home/data/repositories/home_repository_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../domain/entities/home_result.dart';
import '../../domain/entities/progress_summary.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final http.Client _httpClient;
  final String? _accessToken;

  HomeRepositoryImpl({
    required http.Client httpClient,
    String? accessToken,
  })  : _httpClient = httpClient,
        _accessToken = accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  @override
  Future<HomeResult<ProgressSummary>> getProgressSummary() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/users/progress/summary'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final progressSummary = ProgressSummary.fromJson(data);
        return HomeResult.success(progressSummary);
      } else {
        final error = jsonDecode(response.body);
        return HomeResult.failure(error['message'] ?? 'Failed to get progress summary');
      }
    } catch (e) {
      return HomeResult.failure('Network error: ${e.toString()}');
    }
  }
}
