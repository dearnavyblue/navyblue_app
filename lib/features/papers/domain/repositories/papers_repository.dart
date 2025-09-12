// lib/features/papers/domain/repositories/papers_repository.dart
import '../../../../brick/models/exam_paper.model.dart';
import '../entities/papers_response.dart';
import '../entities/paper_filters.dart';
import '../entities/paper_result.dart';

abstract class PapersRepository {
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
  });

  Future<PaperResult<PaperFilters>> getFilterOptions();

  Future<PaperResult<PapersResponse>> searchPapers({
    required String query,
    int? page,
    int? limit,
  });

  Future<PaperResult<ExamPaper>> getPaper(String paperId, {bool includeSolutions = false});

  Future<PaperResult<ExamPaper>> getPaperMetadata(String paperId);

  Future<PaperResult<Map<String, dynamic>>> getPaperPage(String paperId, int pageNumber, {bool includeSolutions = false});
}
