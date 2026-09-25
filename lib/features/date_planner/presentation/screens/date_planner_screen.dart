import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../controllers/date_planner_controller.dart';
import '../widgets/date_itinerary_card.dart';

class DatePlannerScreen extends ConsumerStatefulWidget {
  final String? partnerName;
  final String? matchId;
  final ValueChanged<String>? onShareToChat;

  const DatePlannerScreen({
    super.key,
    this.partnerName,
    this.matchId,
    this.onShareToChat,
  });

  @override
  ConsumerState<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends ConsumerState<DatePlannerScreen> {
  late TextEditingController _cityController;

  final List<String> _vibes = ['cozy', 'adventurous', 'chill', 'romantic', 'cultural'];
  final List<String> _budgets = ['\$', '\$\$', '\$\$\$'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(datePlannerControllerProvider);
    _cityController = TextEditingController(text: state.city);
    if (state.currentPlan == null) {
      Future.microtask(() {
        ref.read(datePlannerControllerProvider.notifier).generatePlan();
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plannerState = ref.watch(datePlannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            const MatchText(
              'ai date planner',
              style: MatchTextStyle.navigation,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const MatchText(
              'plan a date.',
              style: MatchTextStyle.hero,
            ),
            const SizedBox(height: 8),
            Text(
              widget.partnerName != null
                  ? 'curate a seamless date itinerary tailored for you and ${widget.partnerName!.toLowerCase()}.'
                  : 'curate a seamless chronological date itinerary with verified place types.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // City Input
            MatchTextField(
              controller: _cityController,
              label: 'city / neighborhood',
              hintText: 'e.g. Chennai, Besant Nagar',
              onChanged: (val) {
                ref.read(datePlannerControllerProvider.notifier).setCity(val);
              },
            ),
            const SizedBox(height: 20),

            // Vibe Chips
            Text(
              'vibe',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vibes.map((v) {
                final isSelected = plannerState.vibe == v;
                return MatchChip(
                  label: v,
                  isSelected: isSelected,
                  onSelected: () {
                    ref.read(datePlannerControllerProvider.notifier).setVibe(v);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Budget Tier
            Text(
              'budget',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _budgets.map((b) {
                final isSelected = plannerState.budgetTier == b;
                return MatchChip(
                  label: b,
                  isSelected: isSelected,
                  onSelected: () {
                    ref.read(datePlannerControllerProvider.notifier).setBudget(b);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Generate Button
            MatchButton(
              text: 'regenerate itinerary',
              variant: MatchButtonVariant.secondary,
              isLoading: plannerState.isGenerating,
              leadingIcon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
              onPressed: () {
                ref.read(datePlannerControllerProvider.notifier).generatePlan();
              },
            ),
            const SizedBox(height: 32),

            // Plan Display or Loading
            if (plannerState.isGenerating)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: MatchLoadingIndicator(
                    type: MatchLoadingType.thinking,
                    message: 'curating places and timing...',
                  ),
                ),
              )
            else if (plannerState.currentPlan != null) ...[
              DateItineraryCard(plan: plannerState.currentPlan!),
              const SizedBox(height: 20),

              // Quick Modifiers
              Text(
                'refine itinerary',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MatchButton(
                    text: 'make it cheaper',
                    variant: MatchButtonVariant.outline,
                    isFullWidth: false,
                    size: MatchButtonSize.compact,
                    onPressed: () {
                      ref.read(datePlannerControllerProvider.notifier).makeCheaper();
                    },
                  ),
                  MatchButton(
                    text: 'make it adventurous',
                    variant: MatchButtonVariant.outline,
                    isFullWidth: false,
                    size: MatchButtonSize.compact,
                    onPressed: () {
                      ref.read(datePlannerControllerProvider.notifier).makeAdventurous();
                    },
                  ),
                  MatchButton(
                    text: 'make it shorter',
                    variant: MatchButtonVariant.outline,
                    isFullWidth: false,
                    size: MatchButtonSize.compact,
                    onPressed: () {
                      ref.read(datePlannerControllerProvider.notifier).makeShorter();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Share to Chat Action
              if (widget.onShareToChat != null)
                MatchButton(
                  text: 'share itinerary with ${widget.partnerName ?? "match"}',
                  variant: MatchButtonVariant.accent,
                  onPressed: () {
                    final plan = plannerState.currentPlan!;
                    final summary =
                        '📅 Date Plan: "${plan.title}" in ${plan.city}\n• ${plan.itinerary.map((s) => "${s.time} - ${s.title}").join("\n• ")}';
                    widget.onShareToChat!(summary);
                    MatchToast.show(context, message: 'itinerary shared to conversation.');
                    Navigator.of(context).pop();
                  },
                ),
            ],
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
