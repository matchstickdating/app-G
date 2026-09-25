import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/safety_controller.dart';
import 'selfie_verification_screen.dart';

class SafetyCenterScreen extends ConsumerStatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  ConsumerState<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends ConsumerState<SafetyCenterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(authControllerProvider).userId ?? 'current-user';
      ref.read(safetyControllerProvider.notifier).loadVerificationStatus(userId);
    });
  }

  void _showBlockedUsersModal(BuildContext context, SafetyState state, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MatchText('blocked accounts', style: MatchTextStyle.headingSmall),
                const SizedBox(height: 8),
                Text(
                  'blocked users cannot view your profile, send messages, or appear in discovery.',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.blockedUserIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'no blocked accounts.',
                        style: AppTypography.caption(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ...state.blockedUserIds.map((userId) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.block, color: AppColors.error, size: 20),
                      title: Text(userId, style: AppTypography.bodyMedium()),
                      trailing: TextButton(
                        onPressed: () {
                          final currentUserId = ref.read(authControllerProvider).userId ?? 'current-user';
                          ref.read(safetyControllerProvider.notifier).unblockUser(
                                userId: currentUserId,
                                targetUserId: userId,
                              );
                          Navigator.of(context).pop();
                          MatchToast.show(context, message: 'user unblocked.');
                        },
                        child: const Text('unblock'),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyState = ref.watch(safetyControllerProvider);
    final isVerified = safetyState.verification?.isVerified ?? false;
    final isPending = safetyState.verification?.isPending ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'safety center',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const MatchText('your safety first.', style: MatchTextStyle.hero),
            const SizedBox(height: 8),
            Text(
              'intentional connection starts with trust. access verification, safety tools, and emergency resources.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Verification Card
            MatchCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isVerified
                  ? (isDark ? const Color(0xFF14241B) : const Color(0xFFEBF7F0))
                  : null,
              borderColor: isVerified ? AppColors.success : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified
                            : (isPending ? Icons.hourglass_top : Icons.shield_outlined),
                        color: isVerified
                            ? AppColors.success
                            : (isPending ? AppColors.accent : AppColors.accent),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isVerified
                            ? 'photo verified'
                            : (isPending ? 'verification pending' : 'unverified profile'),
                        style: AppTypography.headingSmall().copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVerified
                        ? 'your profile carries the official match stick verified badge.'
                        : (isPending
                            ? 'your selfie is currently being reviewed by our trust & safety team.'
                            : 'complete a quick 30-second pose selfie to verify your identity and earn the badge.'),
                    style: AppTypography.caption(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (!isVerified && !isPending) ...[
                    const SizedBox(height: 16),
                    MatchButton(
                      text: '✦ verify now',
                      variant: MatchButtonVariant.primary,
                      size: MatchButtonSize.compact,
                      onPressed: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: const SelfieVerificationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // In-Person Date Guidelines
            Text(
              'in-person date guidelines',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _buildTipTile(
              icon: Icons.place_outlined,
              title: 'meet in public spaces',
              desc: 'always arrange first dates at reputable cafes, restaurants, or galleries with open foot traffic.',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildTipTile(
              icon: Icons.share_location_outlined,
              title: 'share plans with a friend',
              desc: 'tell a trusted friend where you are meeting, who you are with, and your estimated return time.',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildTipTile(
              icon: Icons.directions_car_outlined,
              title: 'control your transportation',
              desc: 'arrive and depart under your own transit so you have full agency to leave at any moment.',
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildTipTile(
              icon: Icons.lock_outline,
              title: 'protect financial info',
              desc: 'never send money, wire transfers, cryptocurrency, or banking information to anyone.',
              isDark: isDark,
            ),
            const SizedBox(height: 28),

            // Controls & Settings
            Text(
              'moderation & privacy',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            MatchCard(
              onTap: () => _showBlockedUsersModal(context, safetyState, isDark),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.block, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'manage blocked accounts (${safetyState.blockedUserIds.length})',
                      style: AppTypography.bodyMedium(),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Emergency Resources
            Text(
              'emergency resources',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            MatchCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? const Color(0xFF2B1616) : const Color(0xFFFFF0F0),
              borderColor: AppColors.error.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emergency_outlined, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'need immediate help?',
                        style: AppTypography.headingSmall().copyWith(
                          fontSize: 15,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'if you are in immediate danger, please dial local emergency services (112 / 911) or contact the National Crisis Line.',
                    style: AppTypography.caption(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  MatchButton(
                    text: 'call emergency services (112)',
                    variant: MatchButtonVariant.accent,
                    size: MatchButtonSize.compact,
                    onPressed: () {
                      MatchToast.show(context, message: 'connecting to emergency services...');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildTipTile({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return MatchCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toLowerCase(),
                  style: AppTypography.headingSmall().copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
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
      ),
    );
  }
}
