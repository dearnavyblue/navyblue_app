// lib/features/admin/domain/use_cases/update_user_use_case.dart
import 'package:navyblue_app/brick/models/user.model.dart';

import '../entities/admin_result.dart';
import '../repositories/admin_repository.dart';

class UpdateUserUseCase {
  final AdminRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<AdminResult<User>> call(
    String userId, {
    String? role,
    bool? isEmailVerified,
  }) async {
    if (userId.isEmpty) {
      return AdminResult.failure('User ID is required');
    }

    if (role != null && !['USER', 'ADMIN'].contains(role)) {
      return AdminResult.failure('Invalid role. Must be USER or ADMIN');
    }

    return await _repository.updateUser(
      userId,
      role: role,
      isEmailVerified: isEmailVerified,
    );
  }
}
