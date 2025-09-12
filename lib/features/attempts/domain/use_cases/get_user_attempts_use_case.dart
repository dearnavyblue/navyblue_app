// lib/features/attempts/domain/use_cases/get_user_attempts_use_case.dart
import '../entities/user_attempts_response.dart';
import '../entities/attempt_result.dart';
import '../repositories/attempts_repository.dart';
import '../../../../brick/models/student_attempt.model.dart';
import '../../../../brick/models/exam_paper.model.dart';

class GetUserAttemptsUseCase {
  final AttemptsRepository _repository;

  GetUserAttemptsUseCase(this._repository);

  // Default method - fetches all pages (for initial sync)
  Future<AttemptResult<UserAttemptsResponse>> call({
    String? status,
  }) async {
    // Fetch ALL pages for complete sync
    List<StudentAttempt> allAttempts = [];
    Map<String, ExamPaper> allPapers = {};
    int currentPage = 1;
    int totalCount = 0;
    int totalPages = 1;

    print('Fetching all user attempts pages...');

    do {
      final result = await _repository.getUserAttempts(
        page: currentPage,
        limit: 50,
        status: status,
      );

      if (result.isSuccess) {
        final response = result.data!;

        allAttempts.addAll(response.attempts);
        allPapers.addAll(response.papers);

        totalCount = response.totalCount;
        totalPages = response.totalPages;

        currentPage++;
      } else {
        return AttemptResult.failure(
            result.error ?? 'Failed to fetch attempts');
      }
    } while (currentPage <= totalPages);

    print('Total attempts fetched: ${allAttempts.length}');

    final combinedResponse = UserAttemptsResponse(
      attempts: allAttempts,
      papers: allPapers,
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: 1,
    );

    return AttemptResult.success(combinedResponse);
  }

  // NEW: Single page method for pagination
  Future<AttemptResult<UserAttemptsResponse>> getPage({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    print('Fetching attempts page $page (limit: $limit)');

    return await _repository.getUserAttempts(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
