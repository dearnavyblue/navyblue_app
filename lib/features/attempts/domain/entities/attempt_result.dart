// lib/features/attempts/domain/entities/attempt_result.dart
class AttemptResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const AttemptResult.success(this.data)
       : error = null,
         isSuccess = true;

  const AttemptResult.failure(this.error)
       : data = null,
         isSuccess = false;
}