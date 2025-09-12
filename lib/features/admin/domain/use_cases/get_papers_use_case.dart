// lib/features/admin/domain/use_cases/get_papers_use_case.dart
import '../entities/admin_result.dart';
import '../entities/papers_response.dart';
import '../repositories/admin_repository.dart';

class GetPapersUseCase {
  final AdminRepository _repository;

  GetPapersUseCase(this._repository);

  Future<AdminResult<PapersResponse>> call({
    String? subject,
    String? grade,
    bool? isActive,
    int? page,
    int? limit,
  }) async {
    return await _repository.getPapers(
      subject: subject,
      grade: grade,
      isActive: isActive,
      page: page,
      limit: limit,
    );
  }
}