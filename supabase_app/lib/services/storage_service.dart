import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = '$userId/profile_$userId.jpg';

      await _supabase.storage.from('profiles').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      // Add a small delay to ensure the file is fully processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the public URL with a cache-busting timestamp
      final String imageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);

      // Add cache-busting parameter to force reload
      return '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }

  Future<String?> getProfileImageUrl(String userId) async {
    try {
      final String fileName = '$userId/profile_$userId.jpg';

      // Check if file exists first
      final files = await _supabase.storage
          .from('profiles')
          .list(path: userId);

      final fileExists = files.any((file) => file.name == 'profile_$userId.jpg');

      if (!fileExists) {
        return null;
      }

      // Try to get public URL first (if bucket is public)
      try {
        final String publicUrl = _supabase.storage
            .from('profiles')
            .getPublicUrl(fileName);

        // Add cache-busting parameter
        return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      } catch (e) {
        // If public URL fails, try signed URL
        final response = await _supabase.storage
            .from('profiles')
            .createSignedUrl(fileName, 60 * 60);

        return response;
      }
    } catch (error) {
      throw Exception('Failed to get profile image URL: $error');
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      final String fileName = '$userId/profile_$userId.jpg';
      await _supabase.storage.from('profiles').remove([fileName]);
    } catch (error) {
      throw Exception('Failed to delete profile image: $error');
    }
  }

  Future<List<String>> listUserFiles(String userId) async {
    try {
      final files = await _supabase.storage
          .from('profiles')
          .list(path: userId);

      return files.map((file) => file.name).toList();
    } catch (error) {
      throw Exception('Failed to list user files: $error');
    }
  }
}