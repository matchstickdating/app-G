import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_bottom_sheet.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_text.dart';

class CompatibilityBadge extends StatelessWidget {
  final int score;
  final List<String> reasons;

  const CompatibilityBadge({
    super.key,
    required this.score,
    this.reasons = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MatchBottomSheet.show(
          context: context,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score% compatible',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'verified compatibility',
                      style: TextStyle(fontSize: 12, color: AppColors.lightTextTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const MatchText(
                  'why you match',
                  style: MatchTextStyle.headingMedium,
                ),
                const SizedBox(height: 14),
                if (reasons.isNotEmpty) ...[
                  ...reasons.map((reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16, color: AppColors.accent)),
                            Expanded(
                              child: Text(
                                reason.toLowerCase(),
                                style: AppTypography.bodyLarge(),
                              ),
                            ),
                          ],
                        ),
                      )),
                ] else ...[
                  const Text('• aligned lifestyle goals and mutual aesthetic interests.'),
                  const Text('• active in the same geographical neighborhood.'),
                ],
                const SizedBox(height: 28),
                MatchButton(
                  text: 'got it',
                  variant: MatchButtonVariant.primary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 13, color: AppColors.accent),
            const SizedBox(width: 5),
            Text(
              '$score% compatible',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.01 * 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
