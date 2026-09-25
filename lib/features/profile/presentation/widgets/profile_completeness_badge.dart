import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_card.dart';

class ProfileCompletenessBadge extends StatelessWidget {
  final int percentage;
  final VoidCallback? onNudge;

  const ProfileCompletenessBadge({
    super.key,
    required this.percentage,
    this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = percentage >= 100;

    return MatchCard(
      onTap: onNudge,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      backgroundColor: isDark ? const Color(0xFF1B1B1B) : const Color(0xFFF2EFE9),
      borderColor: isComplete
          ? AppColors.success.withValues(alpha: 0.3)
          : AppColors.accent.withValues(alpha: 0.3),
      child: Row(
        children: [
          // Circular progress or checkmark
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  value: percentage / 100.0,
                  strokeWidth: 3,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppColors.success : AppColors.accent,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'profile complete' : 'profile polish: $percentage%',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isComplete
                      ? 'your profile is optimized for intelligent matches.'
                      : 'add another prompt or photo to get 3x more matches.',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isComplete)
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
        ],
      ),
    );
  }
}
