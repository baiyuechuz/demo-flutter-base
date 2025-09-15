import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPhotoPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // For other platforms, assume permission is granted
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't require explicit storage permission for app documents
  }

  Future<PermissionStatus> getPhotoPermissionStatus() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await Permission.photos.status;
    }
    return PermissionStatus.granted;
  }

  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  Future<PermissionStatus> getStoragePermissionStatus() async {
    if (Platform.isAndroid) {
      return await Permission.storage.status;
    }
    return PermissionStatus.granted;
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied. You can grant permission in settings.';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable it in app settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted by system.';
      default:
        return 'Unknown permission status';
    }
  }
}