import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool isLoading;
  final double? width;
  final double? height;
  final MainAxisSize mainAxisSize;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.isLoading = false,
    this.width,
    this.height,
    this.mainAxisSize = MainAxisSize.min,
  });

  factory ActionButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return ActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppConstants.accentColor,
      foregroundColor: AppConstants.textPrimary,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  factory ActionButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return ActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppConstants.secondaryColor,
      foregroundColor: AppConstants.textPrimary,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  factory ActionButton.danger({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return ActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: AppConstants.errorColor,
      foregroundColor: AppConstants.textPrimary,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  factory ActionButton.outline({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    Color? borderColor,
    Color? textColor,
    bool isLoading = false,
    double? width,
    double? height,
  }) {
    return ActionButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      backgroundColor: Colors.transparent,
      foregroundColor: textColor ?? AppConstants.accentColor,
      isLoading: isLoading,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width;
    final effectiveHeight = height ?? 48.0;

    Widget buttonChild = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? AppConstants.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            'Loading...',
            style: AppConstants.button.copyWith(
              color: foregroundColor ?? AppConstants.textPrimary,
            ),
          ),
        ] else ...[
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: foregroundColor ?? AppConstants.textPrimary,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          Text(
            text,
            style: AppConstants.button.copyWith(
              color: foregroundColor ?? AppConstants.textPrimary,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppConstants.accentColor,
          foregroundColor: foregroundColor ?? AppConstants.textPrimary,
          elevation: elevation ?? AppConstants.elevationMedium,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppConstants.radiusMedium),
          ),
          disabledBackgroundColor: (backgroundColor ?? AppConstants.accentColor).withOpacity(0.5),
          disabledForegroundColor: (foregroundColor ?? AppConstants.textPrimary).withOpacity(0.5),
        ),
        child: buttonChild,
      ),
    );
  }
}