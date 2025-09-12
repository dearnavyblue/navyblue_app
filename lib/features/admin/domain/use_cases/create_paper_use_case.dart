// lib/features/admin/domain/use_cases/create_paper_use_case.dart
import 'package:navyblue_app/brick/models/exam_paper.model.dart';

import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class CreatePaperUseCase {
  final AdminRepository _repository;

  CreatePaperUseCase(this._repository);

  Future<AdminResult<ExamPaper>> call(Map<String, dynamic> paperData) async {
    // Basic validation
    if (paperData['title'] == null || paperData['title'].toString().trim().isEmpty) {
      return AdminResult.failure('Paper title is required');
    }
    if (paperData['subject'] == null) {
      return AdminResult.failure('Subject is required');
    }
    if (paperData['grade'] == null) {
      return AdminResult.failure('Grade is required');
    }

    return await _repository.createPaper(paperData);
  }
}