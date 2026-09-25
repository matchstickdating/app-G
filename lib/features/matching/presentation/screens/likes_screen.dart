import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_avatar.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_text.dart';
import 'package:matchstick/features/monetization/presentation/controllers/subscription_controller.dart';
import 'package:matchstick/features/monetization/presentation/screens/paywall_screen.dart';
import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';
import 'package:matchstick/features/profile/presentation/controllers/profile_controller.dart';
import '../widgets/match_celebration_dialog.dart';

class LikesScreen extends ConsumerWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myProfile = ref.watch(profileControllerProvider).profile;
    final isStudioMember = ref.watch(subscriptionControllerProvider).isStudioMember;

    final mockLikes = [
      ProfileEntity(
        id: 'like-marcus',
        displayName: 'Marcus',
        birthdate: DateTime(1998, 9, 21),
        gender: 'man',
        genderPreference: const ['woman'],
        relationshipGoal: 'long_term',
        bio: 'sketching Brutalist facades by day, listening to ambient vinyl by night.',
        locationCity: 'Tokyo',
        locationCountry: 'Japan',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'm1',
            url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        interests: const ['architecture', 'vinyl records', 'specialty coffee'],
        createdAt: DateTime.now(),
      ),
      ProfileEntity(
        id: 'like-elena',
        displayName: 'Elena',
        birthdate: DateTime(2001, 11, 30),
        gender: 'woman',
        genderPreference: const ['man'],
        relationshipGoal: 'long_term',
        bio: 'documentary filmmaker and book collector.',
        locationCity: 'Paris',
        locationCountry: 'France',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'e1',
            url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        interests: const ['literature', 'film & cinema'],
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'likes received',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const MatchText(
              'people interested\nin connecting.',
              style: MatchTextStyle.hero,
            ),
            const SizedBox(height: 8),
            Text(
              'intentional connections waiting for your response.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),

            if (!isStudioMember)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: MatchCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MotionTokens.editorialPageRoute(
                        page: const PaywallScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(16),
                  backgroundColor: isDark ? const Color(0xFF221515) : const Color(0xFFFFF6F6),
                  borderColor: AppColors.accent.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'match stick studio',
                              style: AppTypography.headingSmall().copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'see everyone who likes you with zero delay.',
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
              ),
            ...mockLikes.map((person) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MatchCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      MatchAvatar(
                        name: person.displayName,
                        imageUrl: person.primaryPhotoUrl,
                        size: MatchAvatarSize.large,
                        isVerified: person.isVerified,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${person.displayName.toLowerCase()}, ${person.age}',
                              style: AppTypography.headingSmall(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              person.interests.take(2).join(' • ').toLowerCase(),
                              style: AppTypography.caption(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              person.relationshipGoal.replaceAll('_', ' ').toLowerCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      MatchButton(
                        text: 'match',
                        variant: MatchButtonVariant.accent,
                        isFullWidth: false,
                        size: MatchButtonSize.compact,
                        onPressed: () {
                          if (myProfile != null) {
                            MatchCelebrationDialog.show(
                              context: context,
                              myProfile: myProfile,
                              matchedProfile: person,
                              onStartChat: () {},
                              onKeepLooking: () {},
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
