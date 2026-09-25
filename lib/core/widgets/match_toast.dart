import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ToastType {
  info,
  success,
  error,
}

class MatchToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case ToastType.info:
        bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        icon = Icons.info_outline;
        break;
      case ToastType.success:
        bgColor = isDark ? const Color(0xFF142918) : const Color(0xFFE8F5E9);
        textColor = isDark ? const Color(0xFF81C784) : AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        bgColor = isDark ? const Color(0xFF2C1616) : const Color(0xFFFFEBEE);
        textColor = isDark ? const Color(0xFFE57373) : AppColors.error;
        icon = Icons.error_outline;
        break;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -10 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: textColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message.toLowerCase(),
                      style: AppTypography.bodyMedium(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
