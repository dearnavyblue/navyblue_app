// lib/features/home/domain/entities/home_result.dart
class HomeResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const HomeResult.success(this.data)
      : error = null,
        isSuccess = true;

  const HomeResult.failure(this.error)
      : data = null,
        isSuccess = false;
}