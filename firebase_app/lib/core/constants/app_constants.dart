import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Firebase Demo';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF0b1221);
  static const Color secondaryColor = Color(0xFF1f2937);
  static const Color accentColor = Color(0xFF667eea);
  static const Color backgroundColor = Color(0xFF0b1221);
  static const Color surfaceColor = Color(0xFF111827);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;

  // Border Colors
  static const Color borderLight = Colors.white12;
  static const Color borderMedium = Colors.white24;

  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 32.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 20.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    color: textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    color: textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: textPrimary,
    fontSize: 16,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textTertiary,
    fontSize: 12,
  );

  static const TextStyle button = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Snackbar Durations
  static const Duration snackbarShort = Duration(seconds: 2);
  static const Duration snackbarMedium = Duration(seconds: 3);
  static const Duration snackbarLong = Duration(seconds: 5);

  // Form Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxMessageLength = 200;

  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['.jpg', '.jpeg', '.png', '.gif'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheShort = Duration(minutes: 5);
  static const Duration cacheMedium = Duration(minutes: 30);
  static const Duration cacheLong = Duration(hours: 2);
}