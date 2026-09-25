import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../monetization/presentation/controllers/subscription_controller.dart';
import '../../../monetization/presentation/screens/paywall_screen.dart';
import '../../../safety/presentation/screens/safety_center_screen.dart';
import '../../../safety/presentation/widgets/report_modal.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_completeness_badge.dart';
import '../widgets/profile_photo_carousel.dart';
import '../widgets/profile_prompt_card.dart';
import 'edit_profile_screen.dart';

class ProfileDetailScreen extends ConsumerWidget {
  final bool isMyProfile;
  final VoidCallback? onBack;

  const ProfileDetailScreen({
    super.key,
    this.isMyProfile = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final isStudioMember = ref.watch(subscriptionControllerProvider).isStudioMember;
    final profile = profileState.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileState.isLoading && profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MatchText(
                'nothing here yet.\nyour profile will appear here.',
                style: MatchTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              MatchButton(
                text: 'reload',
                isFullWidth: false,
                onPressed: () {
                  final userId = ref.read(authControllerProvider).userId ?? 'demo-user-1';
                  ref.read(profileControllerProvider.notifier).loadProfile(userId);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Slivers App Bar with Carousel
          SliverAppBar(
            expandedHeight: 460,
            pinned: true,
            leading: onBack != null
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
                    ),
                    onPressed: onBack,
                  )
                : null,
            actions: [
              if (isMyProfile)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Edit Profile',
                  onPressed: () {
                    Navigator.of(context).push(
                      MotionTokens.editorialPageRoute(
                        page: const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProfilePhotoCarousel(
                photos: profile.photos,
                isVerified: profile.isVerified,
                height: 460,
              ),
            ),
          ),

          // Profile Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Completeness Nudge for Owner
                  if (isMyProfile && profileState.completeness < 100) ...[
                    ProfileCompletenessBadge(
                      percentage: profileState.completeness,
                      onNudge: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Headline: Name & Age
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      MatchText(
                        profile.displayName.toLowerCase(),
                        style: MatchTextStyle.hero,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${profile.age}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          letterSpacing: -0.04 * 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location & Relationship Intention Pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (profile.locationCity != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${profile.locationCity}, ${profile.locationCountry ?? ""}'.toLowerCase(),
                                style: AppTypography.caption(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF241515) : const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          profile.relationshipGoal.replaceAll('_', ' ').toLowerCase(),
                          style: AppTypography.caption(
                            color: AppColors.accent,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio Section
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    Text(
                      'about',
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: AppTypography.bodyLarge(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Editorial Prompts
                  if (profile.prompts.isNotEmpty) ...[
                    Text(
                      'prompts',
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...profile.prompts.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ProfilePromptCard(
                            question: p.question,
                            answer: p.answer,
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],

                  // Interests
                  if (profile.interests.isNotEmpty) ...[
                    Text(
                      'curated passions',
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.interests.map((interest) {
                        return MatchChip(
                          label: interest,
                          isSelected: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 36),
                  ],

                  // Edit Profile or Sign Out for Owner
                  if (isMyProfile) ...[
                    // Studio Membership Card
                    MatchCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: const PaywallScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.accent.withValues(alpha: 0.4),
                      backgroundColor: isDark ? const Color(0xFF221515) : const Color(0xFFFFF6F6),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('match stick studio', style: AppTypography.headingSmall().copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  isStudioMember
                                      ? 'active studio membership • enjoy all perks'
                                      : 'see who liked you, unlimited rewinds & priority ai',
                                  style: AppTypography.caption(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Safety Center Card
                    MatchCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: const SafetyCenterScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('safety & trust center', style: AppTypography.headingSmall().copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  'photo verification, in-person guides & emergency help',
                                  style: AppTypography.caption(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    MatchButton(
                      text: 'edit profile',
                      variant: MatchButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    MatchButton(
                      text: 'sign out',
                      variant: MatchButtonVariant.text,
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).signOut();
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    MatchButton(
                      text: 'report or block ${profile.displayName.toLowerCase()}',
                      variant: MatchButtonVariant.text,
                      onPressed: () {
                        ReportModal.show(
                          context: context,
                          targetUserId: profile.id,
                          targetUserName: profile.displayName,
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
