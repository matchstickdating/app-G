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
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          // Rewind button
          if (onRewind != null)
            _buildActionButton(
              label: 'rewind',
              icon: Icons.replay,
              size: 48,
              iconSize: 20,
              color: canRewind
                  ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              onTap: canRewind
                  ? () {
                      HapticFeedback.lightImpact();
                      onRewind?.call();
                    }
                  : null,
              isDark: isDark,
            ),

          // Pass button (X)
          _buildActionButton(
            label: 'pass',
            icon: Icons.close,
            size: 58,
            iconSize: 26,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              onPass();
            },
            isDark: isDark,
          ),

          // Super Like button (Star)
          _buildActionButton(
            label: 'super like',
            icon: Icons.star_border,
            size: 48,
            iconSize: 22,
            color: AppColors.primary,
            onTap: () {
              HapticFeedback.mediumImpact();
              onSuperLike();
            },
            isDark: isDark,
          ),

          // Like button (Accent color)
          _buildActionButton(
            label: 'like',
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
    required String label,
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          enabled: onTap != null,
          label: label,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isFilled
                      ? null
                      : Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: 1.2,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.06),
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
          ),
        ),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
