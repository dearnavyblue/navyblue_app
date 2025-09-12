// lib/features/admin/domain/use_cases/delete_paper_use_case.dart
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class DeletePaperUseCase {
  final AdminRepository _repository;

  DeletePaperUseCase(this._repository);

  Future<AdminResult<void>> call(String paperId) async {
    if (paperId.isEmpty) {
      return AdminResult.failure('Paper ID is required');
    }

    return await _repository.deletePaper(paperId);
  }
}
