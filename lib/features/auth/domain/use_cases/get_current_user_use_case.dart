// lib/features/auth/domain/use_cases/get_current_user_use_case.dart
import 'package:navyblue_app/brick/models/user.model.dart';

import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User?> call() async {
    await _repository.initializeUser();
    return _repository.getCurrentUser();
  }
}