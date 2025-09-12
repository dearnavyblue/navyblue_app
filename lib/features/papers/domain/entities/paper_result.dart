// lib/features/papers/domain/entities/paper_result.dart
class PaperResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const PaperResult.success(this.data) 
      : error = null, 
        isSuccess = true;

  const PaperResult.failure(this.error) 
      : data = null, 
        isSuccess = false;
}