import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;
  final bool showMessage;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size,
    this.showMessage = true,
  });

  factory LoadingIndicator.small({
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      message: message,
      color: color,
      size: 20,
      showMessage: message != null,
    );
  }

  factory LoadingIndicator.medium({
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      message: message,
      color: color,
      size: 32,
      showMessage: message != null,
    );
  }

  factory LoadingIndicator.large({
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      message: message,
      color: color,
      size: 48,
      showMessage: message != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: CircularProgressIndicator(
              strokeWidth: (size ?? 32) / 16,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppConstants.accentColor,
              ),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              message!,
              style: AppConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black54,
            child: LoadingIndicator(
              message: loadingMessage,
              color: indicatorColor,
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatelessWidget {
  final String text;
  final String loadingText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;

  const LoadingButton({
    super.key,
    required this.text,
    this.loadingText = 'Loading...',
    this.onPressed,
    required this.isLoading,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppConstants.accentColor,
          foregroundColor: foregroundColor ?? AppConstants.textPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(loadingText, style: AppConstants.button),
            ] else ...[
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppConstants.paddingSmall),
              ],
              Text(text, style: AppConstants.button),
            ],
          ],
        ),
      ),
    );
  }
}

class PulsingLoadingIndicator extends StatefulWidget {
  final Color? color;
  final double? size;

  const PulsingLoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  State<PulsingLoadingIndicator> createState() => _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<PulsingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size ?? 40,
            height: widget.size ?? 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color ?? AppConstants.accentColor,
            ),
          ),
        );
      },
    );
  }
}