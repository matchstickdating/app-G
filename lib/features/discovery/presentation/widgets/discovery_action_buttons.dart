import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class DiscoveryActionButtons extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final VoidCallback? onRewind;
  final bool canRewind;

  const DiscoveryActionButtons({
    super.key,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    this.onRewind,
    this.canRewind = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rewind button
          _buildActionButton(
            icon: Icons.replay,
            size: 46,
            iconSize: 20,
            color: canRewind
                ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            onTap: canRewind
                ? () {
                    HapticFeedback.lightImpact();
                    onRewind?.call();
                  }
                : null,
            isDark: isDark,
          ),
          const SizedBox(width: 16),

          // Pass button (X)
          _buildActionButton(
            icon: Icons.close,
            size: 58,
            iconSize: 26,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              onPass();
            },
            isDark: isDark,
          ),
          const SizedBox(width: 16),

          // Super Like button (Star)
          _buildActionButton(
            icon: Icons.star_border,
            size: 46,
            iconSize: 22,
            color: const Color(0xFF64B5F6),
            onTap: () {
              HapticFeedback.mediumImpact();
              onSuperLike();
            },
            isDark: isDark,
          ),
          const SizedBox(width: 16),

          // Like button (Accent color)
          _buildActionButton(
            icon: Icons.favorite,
            size: 58,
            iconSize: 26,
            color: AppColors.accent,
            isFilled: true,
            onTap: () {
              HapticFeedback.mediumImpact();
              onLike();
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required Color color,
    required VoidCallback? onTap,
    required bool isDark,
    bool isFilled = false,
  }) {
    final bg = isFilled
        ? AppColors.accent
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final iconColor = isFilled ? Colors.white : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: isFilled
                ? null
                : Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
