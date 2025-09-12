// lib/features/auth/domain/use_cases/logout_use_case.dart
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.logout();
  }
}