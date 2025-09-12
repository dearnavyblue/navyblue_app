// lib/features/admin/domain/repositories/admin_repository.dart

import 'dart:typed_data';
import 'package:navyblue_app/brick/models/exam_paper.model.dart';
import 'package:navyblue_app/brick/models/question.model.dart';
import 'package:navyblue_app/brick/models/question_part.model.dart';
import 'package:navyblue_app/brick/models/solution_step.model.dart';
import 'package:navyblue_app/brick/models/user.model.dart';

import '../entities/admin_result.dart';
import '../entities/image_upload_result.dart';
import '../entities/papers_response.dart';
import '../entities/users_response.dart';

abstract class AdminRepository {
  // Papers
  Future<AdminResult<ExamPaper>> createPaper(Map<String, dynamic> paperData);
  Future<AdminResult<PapersResponse>> getPapers({
    String? subject,
    String? grade,
    bool? isActive,
    int? page,
    int? limit,
  });
  Future<AdminResult<ExamPaper>> getPaper(String paperId);
  Future<AdminResult<void>> deletePaper(String paperId);
  Future<AdminResult<void>> updatePaperStatus(String paperId, bool isActive);
  
  // Questions
  Future<AdminResult<List<Question>>> addQuestionsToPaper(String paperId, List<Map<String, dynamic>> questionsData);
  Future<AdminResult<List<Question>>> getPaperQuestions(String paperId);
  Future<AdminResult<void>> deleteQuestion(String questionId);
  
  // Question Parts
  Future<AdminResult<QuestionPart>> createQuestionPart(String questionId, Map<String, dynamic> partData);
  Future<AdminResult<QuestionPart>> updateQuestionPart(String partId, Map<String, dynamic> updateData);
  Future<AdminResult<void>> deleteQuestionPart(String partId);
  
  // Solution Steps
  Future<AdminResult<SolutionStep>> createSolutionStep(String partId, Map<String, dynamic> stepData);
  Future<AdminResult<SolutionStep>> createDirectSolutionStep(String questionId, Map<String, dynamic> stepData);
  Future<AdminResult<SolutionStep>> updateSolutionStep(String stepId, Map<String, dynamic> updateData);
  Future<AdminResult<void>> deleteSolutionStep(String stepId);
  
  // Users
  Future<AdminResult<UsersResponse>> getUsers({
    String? search,
    String? grade,
    String? role,
    int? page,
    int? limit,
  });
  Future<AdminResult<User>> updateUser(String userId, {String? role, bool? isEmailVerified});
  
  // Images
  Future<ImageUploadResult> uploadImage(Uint8List imageData, String fileName);
}