// lib/features/admin/domain/use_cases/update_paper_status_use_case.dart
import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class UpdatePaperStatusUseCase {
  final AdminRepository _repository;

  UpdatePaperStatusUseCase(this._repository);

  Future<AdminResult<void>> call(String paperId, bool isActive) async {
    if (paperId.isEmpty) {
      return AdminResult.failure('Paper ID is required');
    }

    return await _repository.updatePaperStatus(paperId, isActive);
  }
}
