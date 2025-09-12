// lib/features/admin/domain/use_cases/get_users_use_case.dart
import '../entities/admin_result.dart';
import '../entities/users_response.dart';
import '../repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository _repository;

  GetUsersUseCase(this._repository);

  Future<AdminResult<UsersResponse>> call({
    String? search,
    String? grade,
    String? role,
    int? page,
    int? limit,
  }) async {
    return await _repository.getUsers(
      search: search,
      grade: grade,
      role: role,
      page: page,
      limit: limit,
    );
  }
}

