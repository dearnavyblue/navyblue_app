// lib/features/admin/domain/use_cases/upload_image_use_case.dart
import 'dart:typed_data';
import '../entities/image_upload_result.dart';
import '../repositories/admin_repository.dart';

class UploadImageUseCase {
  final AdminRepository _repository;

  UploadImageUseCase(this._repository);

  Future<ImageUploadResult> call(Uint8List imageData, String fileName) async {
    // Basic validation
    if (imageData.isEmpty) {
      return ImageUploadResult.failure('Image data is required');
    }

    if (fileName.isEmpty) {
      return ImageUploadResult.failure('File name is required');
    }

    // Check file extension
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension = validExtensions.any(
      (ext) => fileName.toLowerCase().endsWith(ext),
    );

    if (!hasValidExtension) {
      return ImageUploadResult.failure('Invalid file type. Supported: JPG, PNG, GIF, WebP');
    }

    return await _repository.uploadImage(imageData, fileName);
  }
}