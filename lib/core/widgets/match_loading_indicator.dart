import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum MatchLoadingType {
  dots,
  thinking,
  pulse,
}

class MatchLoadingIndicator extends StatefulWidget {
  final MatchLoadingType type;
  final String? message;
  final Color? color;

  const MatchLoadingIndicator({
    super.key,
    this.type = MatchLoadingType.dots,
    this.message,
    this.color,
  });

  @override
  State<MatchLoadingIndicator> createState() => _MatchLoadingIndicatorState();
}

class _MatchLoadingIndicatorState extends State<MatchLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (widget.type == MatchLoadingType.thinking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14159,
                child: Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.accent,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            (widget.message ?? 'thinking...').toLowerCase(),
            style: AppTypography.bodyMedium(color: secondaryColor),
          ),
        ],
      );
    }

    if (widget.type == MatchLoadingType.pulse) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 0.85 + (0.3 * (0.5 - (0.5 - _controller.value).abs()));
          final opacity = 0.4 + (0.6 * (0.5 - (0.5 - _controller.value).abs()));
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // Default: Elegant 3-dot wave
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = (_controller.value - delay) % 1.0;
            final opacity = (0.25 + 0.75 * (1 - (progress - 0.5).abs() * 2)).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
