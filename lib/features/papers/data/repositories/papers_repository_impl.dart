// lib/features/papers/data/repositories/papers_repository_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../brick/models/exam_paper.model.dart';
import '../../../../brick/models/question.model.dart';
import '../../../../brick/models/paper_filters.model.dart' as brick;
import '../../domain/entities/papers_response.dart';
import '../../domain/entities/paper_filters.dart' as domain;
import '../../domain/entities/paper_result.dart';
import '../../domain/repositories/papers_repository.dart';

class PapersRepositoryImpl implements PapersRepository {
  final http.Client _httpClient;
  final String? _accessToken;

  PapersRepositoryImpl({
    required http.Client httpClient,
    String? accessToken,
  })  : _httpClient = httpClient,
        _accessToken = accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  @override
  Future<PaperResult<PapersResponse>> getPapers({
    String? subject,
    String? grade,
    String? syllabus,
    int? year,
    String? paperType,
    String? examPeriod,
    String? province,
    String? search,
    int? page,
    int? limit,
    String? sortBy,
    String? sortType,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (subject != null) queryParams['subject'] = subject;
      if (grade != null) queryParams['grade'] = grade;
      if (syllabus != null) queryParams['syllabus'] = syllabus;
      if (year != null) queryParams['year'] = year.toString();
      if (paperType != null) queryParams['paperType'] = paperType;
      if (examPeriod != null) queryParams['examPeriod'] = examPeriod;
      if (province != null) queryParams['province'] = province;
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortType != null) queryParams['sortType'] = sortType;

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/papers')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final papersResponse = PapersResponse.fromJson(data);
        return PaperResult.success(papersResponse);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(error['message'] ?? 'Failed to get papers');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PaperResult<domain.PaperFilters>> getFilterOptions() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/papers/filters'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final filters = domain.PaperFilters.fromJson(data);
        return PaperResult.success(filters);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(
            error['message'] ?? 'Failed to get filter options');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PaperResult<PapersResponse>> searchPapers({
    required String query,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/papers/search')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final papersResponse = PapersResponse.fromJson(data);
        return PaperResult.success(papersResponse);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(error['message'] ?? 'Search failed');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PaperResult<ExamPaper>> getPaper(String paperId,
      {bool includeSolutions = false}) async {
    try {
      final queryParams = <String, String>{};
      if (includeSolutions) queryParams['solutions'] = 'true';

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/papers/$paperId')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paper = ExamPaper.fromJson(data);
        return PaperResult.success(paper);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(error['message'] ?? 'Failed to get paper');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PaperResult<ExamPaper>> getPaperMetadata(String paperId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/papers/$paperId/metadata'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paper = ExamPaper.fromJson(data);
        return PaperResult.success(paper);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(
            error['message'] ?? 'Failed to get paper metadata');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<PaperResult<Map<String, dynamic>>> getPaperPage(
      String paperId, int pageNumber,
      {bool includeSolutions = false}) async {
    try {
      final queryParams = <String, String>{};
      if (includeSolutions) queryParams['solutions'] = 'true';

      final uri =
          Uri.parse('${AppConfig.apiBaseUrl}/papers/$paperId/pages/$pageNumber')
              .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse the response
        final result = {
          'paper': ExamPaper.fromJson(data['paper']),
          'questions': (data['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList(),
          'currentPage': data['currentPage'],
          'totalPages': data['totalPages'],
        };

        return PaperResult.success(result);
      } else {
        final error = jsonDecode(response.body);
        return PaperResult.failure(
            error['message'] ?? 'Failed to get paper page');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }

  // NEW: Method to sync brick filters with server filters
  Future<PaperResult<brick.PaperFilters>> getBrickFilterOptions() async {
    try {
      final result = await getFilterOptions();

      if (result.isSuccess) {
        final domainFilters = result.data!;

        // Convert domain filters to brick filters
        final brickFilters = brick.PaperFilters(
          id: 'server_filters_${DateTime.now().millisecondsSinceEpoch}',
          subjects: domainFilters.subjects,
          grades: domainFilters.grades,
          syllabi: domainFilters.syllabi,
          years: domainFilters.years,
          paperTypes: domainFilters.paperTypes,
          provinces: domainFilters.provinces,
          examPeriods: [], // Add these fields to domain model if needed
          examLevels: [], // Add these fields to domain model if needed
          updatedAt: DateTime.now(),
        );

        return PaperResult.success(brickFilters);
      } else {
        return PaperResult.failure(
            result.error ?? 'Failed to get brick filter options');
      }
    } catch (e) {
      return PaperResult.failure('Network error: ${e.toString()}');
    }
  }
}
