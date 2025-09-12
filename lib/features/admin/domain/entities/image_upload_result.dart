// lib/features/admin/domain/entities/image_upload_result.dart
class ImageUploadResult {
  final bool isSuccess;
  final String? url;
  final String? error;

  const ImageUploadResult._({
    required this.isSuccess,
    this.url,
    this.error,
  });

  factory ImageUploadResult.success(String url) {
    return ImageUploadResult._(isSuccess: true, url: url);
  }

  factory ImageUploadResult.failure(String error) {
    return ImageUploadResult._(isSuccess: false, error: error);
  }
}