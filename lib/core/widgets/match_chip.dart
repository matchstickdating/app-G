import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MatchChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final Widget? icon;
  final bool isRemovable;
  final VoidCallback? onRemoved;

  const MatchChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.isRemovable = false,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final selectedBg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final unselectedText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final selectedText = isDark ? Colors.black : Colors.white;

    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return AnimatedContainer(
      duration: MotionTokens.durationMicro,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? Colors.transparent : unselectedBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onSelected != null
              ? () {
                  HapticFeedback.selectionClick();
                  onSelected!();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 6),
                ],
                Text(
                  label.toLowerCase(),
                  style: AppTypography.chip(
                    color: isSelected ? selectedText : unselectedText,
                  ),
                ),
                if (isRemovable) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onRemoved,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: isSelected ? selectedText : unselectedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
