import 'package:navyblue_app/brick/models/exam_paper.model.dart';

import '../entities/papers_response.dart';
import '../entities/paper_result.dart';
import '../repositories/papers_repository.dart';

class GetPapersUseCase {
  final PapersRepository _repository;

  GetPapersUseCase(this._repository);

  Future<PaperResult<PapersResponse>> call({
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
    // If no page specified, fetch ALL pages (like attempts does)
    if (page == null) {
      List<ExamPaper> allPapers = [];
      int currentPage = 1;
      int totalCount = 0;
      int totalPages = 1;

      print('Fetching all papers pages...');

      do {
        final result = await _repository.getPapers(
          subject: subject,
          grade: grade,
          syllabus: syllabus,
          year: year,
          paperType: paperType,
          examPeriod: examPeriod,
          province: province,
          search: search,
          page: currentPage,
          limit: 50,
          sortBy: sortBy,
          sortType: sortType,
        );

        if (result.isSuccess) {
          final response = result.data!;
          allPapers.addAll(response.papers);
          totalCount = response.totalCount;
          totalPages = response.totalPages;
          currentPage++;
        } else {
          return PaperResult.failure(result.error ?? 'Failed to fetch papers');
        }
      } while (currentPage <= totalPages);

      print('Total papers fetched: ${allPapers.length}');

      final combinedResponse = PapersResponse(
        papers: allPapers,
        totalCount: totalCount,
        totalPages: totalPages,
        currentPage: 1,
      );

      return PaperResult.success(combinedResponse);
    }

    // Otherwise, single page (existing logic)
    return await _repository.getPapers(
      subject: subject,
      grade: grade,
      syllabus: syllabus,
      year: year,
      paperType: paperType,
      examPeriod: examPeriod,
      province: province,
      search: search,
      page: page,
      limit: limit,
      sortBy: sortBy,
      sortType: sortType,
    );
  }
}
