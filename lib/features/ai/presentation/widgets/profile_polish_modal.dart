import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_bottom_sheet.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../controllers/ai_controller.dart';

class ProfilePolishModal extends ConsumerStatefulWidget {
  final String originalText;
  final String title;
  final ValueChanged<String> onApply;

  const ProfilePolishModal({
    super.key,
    required this.originalText,
    required this.title,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required String originalText,
    required String title,
    required ValueChanged<String> onApply,
  }) {
    return MatchBottomSheet.show(
      context: context,
      child: ProfilePolishModal(
        originalText: originalText,
        title: title,
        onApply: onApply,
      ),
    );
  }

  @override
  ConsumerState<ProfilePolishModal> createState() => _ProfilePolishModalState();
}

class _ProfilePolishModalState extends ConsumerState<ProfilePolishModal> {
  String? _selectedSuggestion;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(aiControllerProvider.notifier).polishProfile(bio: widget.originalText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              const MatchText(
                'profile polish',
                style: MatchTextStyle.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'minimal, punchy phrasing. you stay in complete control of your profile.',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Original Text
          Text(
            'current draft',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          MatchCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
            child: Text(
              widget.originalText.isEmpty ? 'empty bio' : widget.originalText,
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Polished Suggestions
          Text(
            'editorial suggestions',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          if (aiState.isGenerating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: MatchLoadingIndicator(
                  type: MatchLoadingType.thinking,
                  message: 'polishing your wording...',
                ),
              ),
            )
          else ...[
            ...aiState.polishSuggestions.map((suggestion) {
              final isSelected = _selectedSuggestion == suggestion;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MatchCard(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSuggestion = suggestion);
                  },
                  padding: const EdgeInsets.all(16),
                  borderColor: isSelected ? AppColors.accent : null,
                  backgroundColor: isSelected
                      ? (isDark ? const Color(0xFF241515) : const Color(0xFFFFF5F5))
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          suggestion,
                          style: AppTypography.bodyMedium(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ).copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, size: 18, color: AppColors.accent),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 20),

          // Apply Button
          MatchButton(
            text: 'apply suggestion',
            variant: MatchButtonVariant.primary,
            onPressed: _selectedSuggestion != null
                ? () {
                    widget.onApply(_selectedSuggestion!);
                    Navigator.of(context).pop();
                  }
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
