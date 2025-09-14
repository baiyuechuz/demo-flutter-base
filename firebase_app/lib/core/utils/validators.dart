import '../constants/app_constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }

    if (value.trim().length > AppConstants.maxTitleLength) {
      return 'Title must be ${AppConstants.maxTitleLength} characters or less';
    }

    return null;
  }

  static String? description(String? value) {
    if (value != null && value.trim().length > AppConstants.maxDescriptionLength) {
      return 'Description must be ${AppConstants.maxDescriptionLength} characters or less';
    }
    return null;
  }

  static String? message(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    if (value.trim().length > AppConstants.maxMessageLength) {
      return 'Message must be ${AppConstants.maxMessageLength} characters or less';
    }

    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }

    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Display name must be 50 characters or less';
    }

    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[^\d+]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be $maxLength characters or less';
    }

    return null;
  }

  static String? numberOnly(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} must contain only numbers';
    }

    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  // File validators
  static String? fileSize(int fileSize, {int? maxSize}) {
    final maxFileSize = maxSize ?? AppConstants.maxFileSize;
    if (fileSize > maxFileSize) {
      return 'File size must be less than ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return null;
  }

  static String? fileType(String fileName, List<String> allowedTypes) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    if (!allowedTypes.contains(extension)) {
      return 'File type not supported. Allowed types: ${allowedTypes.join(', ')}';
    }
    return null;
  }
}