// lib/features/admin/data/repositories/admin_repository_impl.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import '../../../../core/config/app_config.dart';
import '../../../../brick/models/exam_paper.model.dart';
import '../../../../brick/models/user.model.dart';
import '../../domain/entities/admin_result.dart';
import '../../domain/entities/image_upload_result.dart';
import '../../domain/entities/papers_response.dart';
import '../../domain/entities/users_response.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final http.Client _httpClient;
  final String? _accessToken;

  AdminRepositoryImpl({
    required http.Client httpClient,
    required String? accessToken,
  })  : _httpClient = httpClient,
        _accessToken = accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  @override
  Future<AdminResult<ExamPaper>> createPaper(
      Map<String, dynamic> paperData) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/papers'),
        headers: _headers,
        body: jsonEncode(paperData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paper = ExamPaper.fromJson(data);
        return AdminResult.success(paper);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to create paper');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<PapersResponse>> getPapers({
    String? subject,
    String? grade,
    bool? isActive,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (subject != null) queryParams['subject'] = subject;
      if (grade != null) queryParams['grade'] = grade;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/admin/papers')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final papersResponse = PapersResponse.fromJson(data);
        return AdminResult.success(papersResponse);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(error['message'] ?? 'Failed to get papers');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<ExamPaper>> getPaper(String paperId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/papers/$paperId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paper = ExamPaper.fromJson(data);
        return AdminResult.success(paper);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(error['message'] ?? 'Failed to get paper');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<void>> deletePaper(String paperId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/papers/$paperId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return AdminResult.success(null);
      } else if (response.statusCode >= 400) {
        try {
          final error = jsonDecode(response.body);
          return AdminResult.failure(
              error['message'] ?? 'Failed to delete paper');
        } catch (e) {
          return AdminResult.failure(
              'Failed to delete paper (${response.statusCode})');
        }
      } else {
        return AdminResult.failure(
            'Unexpected response: ${response.statusCode}');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<void>> updatePaperStatus(
      String paperId, bool isActive) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/papers/$paperId/status'),
        headers: _headers,
        body: jsonEncode({'isActive': isActive}),
      );

      if (response.statusCode == 200) {
        return AdminResult.success(null);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to update paper status');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<List<Question>>> addQuestionsToPaper(
      String paperId, List<Map<String, dynamic>> questionsData) async {
    try {
      final List<Question> addedQuestions = [];

      // Add each question individually as per your API
      for (final questionData in questionsData) {
        final response = await _httpClient.post(
          Uri.parse('${AppConfig.apiBaseUrl}/admin/papers/$paperId/questions'),
          headers: _headers,
          body: jsonEncode(questionData),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final question = Question.fromJson(data);
          addedQuestions.add(question);
        } else {
          final error = jsonDecode(response.body);
          return AdminResult.failure(error['message'] ??
              'Failed to add question ${questionData['questionNumber']}');
        }
      }

      return AdminResult.success(addedQuestions);
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<UsersResponse>> getUsers({
    String? search,
    String? grade,
    String? role,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null) queryParams['search'] = search;
      if (grade != null) queryParams['grade'] = grade;
      if (role != null) queryParams['role'] = role;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/admin/users')
          .replace(queryParameters: queryParams);

      final response = await _httpClient.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usersResponse = UsersResponse.fromJson(data);
        return AdminResult.success(usersResponse);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(error['message'] ?? 'Failed to get users');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<User>> updateUser(String userId,
      {String? role, bool? isEmailVerified}) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (role != null) updateData['role'] = role;
      if (isEmailVerified != null) {
        updateData['isEmailVerified'] = isEmailVerified;
      }

      final response = await _httpClient.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/users/$userId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        return AdminResult.success(user);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(error['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<ImageUploadResult> uploadImage(
      Uint8List imageData, String fileName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/admin/upload-image'),
      );

      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageData,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImageUploadResult.success(data['url']);
      } else {
        final error = jsonDecode(response.body);
        return ImageUploadResult.failure(
            error['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      return ImageUploadResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<List<Question>>> getPaperQuestions(String paperId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/papers/$paperId/questions'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final questions = (data['questions'] as List)
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();
        return AdminResult.success(questions);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to get paper questions');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<void>> deleteQuestion(String questionId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/questions/$questionId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return AdminResult.success(null);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to delete question');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<QuestionPart>> createQuestionPart(
      String questionId, Map<String, dynamic> partData) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/questions/$questionId/parts'),
        headers: _headers,
        body: jsonEncode(partData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final part = QuestionPart.fromJson(data);
        return AdminResult.success(part);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to create question part');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<QuestionPart>> updateQuestionPart(
      String partId, Map<String, dynamic> updateData) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/parts/$partId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final part = QuestionPart.fromJson(data);
        return AdminResult.success(part);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to update question part');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<void>> deleteQuestionPart(String partId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/parts/$partId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return AdminResult.success(null);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to delete question part');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<SolutionStep>> createSolutionStep(
      String partId, Map<String, dynamic> stepData) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/parts/$partId/solutions'),
        headers: _headers,
        body: jsonEncode(stepData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final step = SolutionStep.fromJson(data);
        return AdminResult.success(step);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to create solution step');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
Future<AdminResult<SolutionStep>> createDirectSolutionStep(
    String questionId, Map<String, dynamic> stepData) async {
  try {
    final response = await _httpClient.post(
      Uri.parse('${AppConfig.apiBaseUrl}/admin/questions/$questionId/solutions'),
      headers: _headers,
      body: jsonEncode(stepData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final step = SolutionStep.fromJson(data);
      return AdminResult.success(step);
    } else {
      final error = jsonDecode(response.body);
      return AdminResult.failure(
          error['message'] ?? 'Failed to create direct solution step');
    }
  } catch (e) {
    return AdminResult.failure('Network error: ${e.toString()}');
  }
}

  @override
  Future<AdminResult<SolutionStep>> updateSolutionStep(
      String stepId, Map<String, dynamic> updateData) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/solutions/$stepId'),
        headers: _headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final step = SolutionStep.fromJson(data);
        return AdminResult.success(step);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to update solution step');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }

  @override
  Future<AdminResult<void>> deleteSolutionStep(String stepId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/admin/solutions/$stepId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return AdminResult.success(null);
      } else {
        final error = jsonDecode(response.body);
        return AdminResult.failure(
            error['message'] ?? 'Failed to delete solution step');
      }
    } catch (e) {
      return AdminResult.failure('Network error: ${e.toString()}');
    }
  }
}
