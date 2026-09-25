import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_bottom_sheet.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/safety_controller.dart';

class ReportModal extends ConsumerStatefulWidget {
  final String targetUserId;
  final String targetUserName;

  const ReportModal({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
  });

  static Future<void> show({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
  }) {
    return MatchBottomSheet.show(
      context: context,
      child: ReportModal(
        targetUserId: targetUserId,
        targetUserName: targetUserName,
      ),
    );
  }

  @override
  ConsumerState<ReportModal> createState() => _ReportModalState();
}

class _ReportModalState extends ConsumerState<ReportModal> {
  final _detailsController = TextEditingController();
  String _selectedReason = 'harassment or hate speech';

  final List<String> _reasons = [
    'harassment or hate speech',
    'impersonation or fake profile',
    'scam or commercial solicitation',
    'inappropriate or explicit photos',
    'offline safety concern',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final currentUserId = ref.read(authControllerProvider).userId ?? 'current-user';

    final success = await ref.read(safetyControllerProvider.notifier).reportUser(
          reporterId: currentUserId,
          reportedUserId: widget.targetUserId,
          reportedUserName: widget.targetUserName,
          reason: _selectedReason,
          details: _detailsController.text.trim(),
        );

    if (mounted) {
      if (success) {
        MatchToast.show(
          context,
          message: 'report submitted. ${widget.targetUserName.toLowerCase()} has been blocked.',
          type: ToastType.success,
        );
        Navigator.of(context).pop();
      } else {
        MatchToast.show(
          context,
          message: 'failed to submit report. please try again.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyState = ref.watch(safetyControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              MatchText(
                'report ${widget.targetUserName.toLowerCase()}',
                style: MatchTextStyle.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'your report is confidential. we will review it promptly to ensure community safety.',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Reason Selector
          Text(
            'reason for report',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return MatchChip(
                label: reason,
                isSelected: isSelected,
                onSelected: () => setState(() => _selectedReason = reason),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Details textfield
          MatchTextField(
            controller: _detailsController,
            label: 'additional details (optional)',
            hintText: 'describe what happened...',
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 20),

          // Disclaimer card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'submitting this report will also automatically block ${widget.targetUserName.toLowerCase()} from contacting you.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          MatchButton(
            text: 'submit report & block',
            variant: MatchButtonVariant.accent,
            isLoading: safetyState.isSubmitting,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
