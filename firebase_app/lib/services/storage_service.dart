import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      SettableMetadata? settableMetadata;
      if (metadata != null) {
        settableMetadata = SettableMetadata(
          customMetadata: metadata,
        );
      }

      final uploadTask = await ref.putFile(file, settableMetadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Storage upload failed: ${e.message}');
    } catch (error) {
      throw Exception('File upload failed: $error');
    }
  }

  Future<String> uploadData({
    required String path,
    required Uint8List data,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);

      SettableMetadata? settableMetadata;
      if (metadata != null) {
        settableMetadata = SettableMetadata(
          customMetadata: metadata,
        );
      }

      final uploadTask = await ref.putData(data, settableMetadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Storage upload failed: ${e.message}');
    } catch (error) {
      throw Exception('Data upload failed: $error');
    }
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final path = 'users/$userId/profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadFile(
        path: path,
        file: imageFile,
        metadata: {
          'userId': userId,
          'type': 'profile_image',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (error) {
      throw Exception('Profile image upload failed: $error');
    }
  }

  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get download URL: ${e.message}');
    } catch (error) {
      throw Exception('Download URL retrieval failed: $error');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('File deletion failed: ${e.message}');
    } catch (error) {
      throw Exception('Delete operation failed: $error');
    }
  }

  Future<void> deleteFileByUrl(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('File deletion failed: ${e.message}');
    } catch (error) {
      throw Exception('Delete operation failed: $error');
    }
  }

  Future<List<Reference>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result.items;
    } on FirebaseException catch (e) {
      throw Exception('Failed to list files: ${e.message}');
    } catch (error) {
      throw Exception('List operation failed: $error');
    }
  }

  Future<List<String>> getUserFiles(String userId) async {
    try {
      final files = await listFiles('users/$userId');
      final List<String> downloadUrls = [];

      for (final file in files) {
        try {
          final url = await file.getDownloadURL();
          downloadUrls.add(url);
        } catch (e) {
          // Skip files that can't be accessed
        }
      }

      return downloadUrls;
    } catch (error) {
      throw Exception('Failed to get user files: $error');
    }
  }

  Future<FullMetadata> getFileMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get metadata: ${e.message}');
    } catch (error) {
      throw Exception('Metadata retrieval failed: $error');
    }
  }

  Future<void> updateMetadata(String path, Map<String, String> metadata) async {
    try {
      final ref = _storage.ref().child(path);
      final settableMetadata = SettableMetadata(customMetadata: metadata);
      await ref.updateMetadata(settableMetadata);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update metadata: ${e.message}');
    } catch (error) {
      throw Exception('Metadata update failed: $error');
    }
  }

  Stream<TaskSnapshot> uploadFileWithProgress({
    required String path,
    required File file,
    Map<String, String>? metadata,
  }) {
    final ref = _storage.ref().child(path);

    SettableMetadata? settableMetadata;
    if (metadata != null) {
      settableMetadata = SettableMetadata(customMetadata: metadata);
    }

    final uploadTask = ref.putFile(file, settableMetadata);
    return uploadTask.snapshotEvents;
  }

  Stream<TaskSnapshot> uploadDataWithProgress({
    required String path,
    required Uint8List data,
    Map<String, String>? metadata,
  }) {
    final ref = _storage.ref().child(path);

    SettableMetadata? settableMetadata;
    if (metadata != null) {
      settableMetadata = SettableMetadata(customMetadata: metadata);
    }

    final uploadTask = ref.putData(data, settableMetadata);
    return uploadTask.snapshotEvents;
  }

  Future<Uint8List?> downloadFileAsBytes(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getData();
    } on FirebaseException catch (e) {
      throw Exception('File download failed: ${e.message}');
    } catch (error) {
      throw Exception('Download operation failed: $error');
    }
  }

  Future<void> deleteUserFiles(String userId) async {
    try {
      final files = await listFiles('users/$userId');
      for (final file in files) {
        await file.delete();
      }
    } catch (error) {
      throw Exception('Failed to delete user files: $error');
    }
  }
}