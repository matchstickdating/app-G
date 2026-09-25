import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subState = ref.watch(subscriptionControllerProvider);
    final isAnnual = subState.selectedPlanId == 'studio_annual';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            size: 20,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final userId = ref.read(authControllerProvider).userId ?? 'current-user';
              ref.read(subscriptionControllerProvider.notifier).restore(userId);
              MatchToast.show(context, message: 'purchases restored.');
            },
            child: Text(
              'restore',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Studio Header Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                    SizedBox(width: 6),
                    Text(
                      'MATCH STICK STUDIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const MatchText(
              'elevate your journey.',
              style: MatchTextStyle.hero,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'experience dating with full clarity, unlimited intentionality, and complete conversational intelligence.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Benefits List
            _buildBenefitRow(
              icon: Icons.favorite_outline,
              title: 'see who liked you',
              desc: 'unblur all incoming likes instantly and match on your own schedule.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(
              icon: Icons.replay,
              title: 'unlimited rewinds',
              desc: 'never lose an intentional profile because of a mistaken swipe.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(
              icon: Icons.calendar_today_outlined,
              title: 'unlimited ai date planner',
              desc: 'curate multi-stop chronological date itineraries tailored to any neighborhood.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(
              icon: Icons.auto_awesome,
              title: 'priority conversational polish',
              desc: 'access private match coach advice and bespoke context-aware starters.',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildBenefitRow(
              icon: Icons.workspace_premium_outlined,
              title: 'studio member badge',
              desc: 'stand out with an exclusive bronze studio emblem on your profile.',
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // Plan Options
            Row(
              children: [
                // Annual Plan Card
                Expanded(
                  child: MatchCard(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(subscriptionControllerProvider.notifier).selectPlan('studio_annual');
                    },
                    padding: const EdgeInsets.all(16),
                    borderColor: isAnnual ? AppColors.accent : null,
                    backgroundColor: isAnnual
                        ? (isDark ? const Color(0xFF2B1616) : const Color(0xFFFFF0F0))
                        : null,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'save 50%',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const MatchText('annual', style: MatchTextStyle.headingSmall),
                        const SizedBox(height: 6),
                        const Text(
                          '\$7.49',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '/month',
                          style: AppTypography.caption(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$89.99 billed yearly',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Monthly Plan Card
                Expanded(
                  child: MatchCard(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(subscriptionControllerProvider.notifier).selectPlan('studio_monthly');
                    },
                    padding: const EdgeInsets.all(16),
                    borderColor: !isAnnual ? AppColors.accent : null,
                    backgroundColor: !isAnnual
                        ? (isDark ? const Color(0xFF2B1616) : const Color(0xFFFFF0F0))
                        : null,
                    child: Column(
                      children: [
                        const SizedBox(height: 19),
                        const MatchText('monthly', style: MatchTextStyle.headingSmall),
                        const SizedBox(height: 6),
                        const Text(
                          '\$14.99',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '/month',
                          style: AppTypography.caption(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'billed monthly',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Purchase Button
            MatchButton(
              text: 'start match stick studio',
              variant: MatchButtonVariant.accent,
              isLoading: subState.isPurchasing,
              onPressed: () async {
                final userId = ref.read(authControllerProvider).userId ?? 'current-user';
                final success = await ref
                    .read(subscriptionControllerProvider.notifier)
                    .purchaseCurrentPlan(userId);

                if (context.mounted && success) {
                  MatchToast.show(
                    context,
                    message: 'welcome to studio. all entitlements are active.',
                    type: ToastType.success,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 14),

            // Cancel Anytime Footer
            Center(
              child: Text(
                'cancel anytime via account settings. terms & privacy apply.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toLowerCase(),
                style: AppTypography.headingSmall().copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
