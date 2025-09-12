// lib/features/admin/domain/entities/admin_result.dart
class AdminResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  const AdminResult._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory AdminResult.success(T data) {
    return AdminResult._(isSuccess: true, data: data);
  }

  factory AdminResult.failure(String error) {
    return AdminResult._(isSuccess: false, error: error);
  }
}