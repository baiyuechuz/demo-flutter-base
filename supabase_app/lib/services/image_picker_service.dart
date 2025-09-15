import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery({
    int maxWidth = 512,
    int maxHeight = 512,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to pick image from gallery: $error');
    }
  }

  Future<File?> pickImageFromCamera({
    int maxWidth = 512,
    int maxHeight = 512,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (error) {
      throw Exception('Failed to take picture with camera: $error');
    }
  }

  Future<List<File>> pickMultipleImages({
    int maxWidth = 512,
    int maxHeight = 512,
    int imageQuality = 80,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (error) {
      throw Exception('Failed to pick multiple images: $error');
    }
  }
}