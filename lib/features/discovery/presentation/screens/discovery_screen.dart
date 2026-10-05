import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../chat/presentation/screens/chat_conversation_screen.dart';
import '../../../matching/presentation/widgets/match_celebration_dialog.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/profile_detail_screen.dart';
import '../controllers/discovery_controller.dart';
import '../widgets/discovery_action_buttons.dart';
import '../widgets/discovery_card.dart';
import '../widgets/discovery_header.dart';
import '../widgets/people_search.dart';
import '../../../profile/domain/entities/profile_entity.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryControllerProvider);
    final myProfile = ref.watch(profileControllerProvider).profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for mutual match detection to trigger celebration modal
    ref.listen(discoveryControllerProvider, (prev, next) {
      if (next.matchedCard != null &&
          prev?.matchedCard != next.matchedCard &&
          myProfile != null) {
        MatchCelebrationDialog.show(
          context: context,
          myProfile: myProfile,
          matchedProfile: next.matchedCard!.profile,
          onStartChat: () {
            ref.read(discoveryControllerProvider.notifier).clearMatch();
            Navigator.of(context).push(
              MotionTokens.editorialPageRoute(
                page: ChatConversationScreen(
                  matchId: 'match-${next.matchedCard!.profile.id}',
                  partnerProfile: next.matchedCard!.profile,
                ),
              ),
            );
          },
          onKeepLooking: () {
            ref.read(discoveryControllerProvider.notifier).clearMatch();
          },
        );
      }
    });

    final hasPhoto = !state.isLoading && state.hasMoreCards;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: hasPhoto ? const Color(0xFF101311) : null,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textExtra = math.max(
                  0.0,
                  MediaQuery.textScalerOf(context).scale(38) - 38,
                );
                return SingleChildScrollView(
                  child: SizedBox(
                    height: math.max(
                      constraints.maxHeight,
                      680 + textExtra * 4,
                    ),
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasPhoto)
                            DiscoveryCard(
                              key: ValueKey(state.currentCard?.profile.id),
                              card: state.currentCard!,
                              onSwipeRight: () {
                                ref
                                    .read(discoveryControllerProvider.notifier)
                                    .swipeRight();
                              },
                              onSwipeLeft: () {
                                ref
                                    .read(discoveryControllerProvider.notifier)
                                    .swipeLeft();
                              },
                              onSwipeUp: () {
                                ref
                                    .read(discoveryControllerProvider.notifier)
                                    .swipeUp();
                              },
                              onTap: () {
                                Navigator.of(context).push(
                                  MotionTokens.editorialPageRoute(
                                    page: ProfileDetailScreen(
                                      isMyProfile: false,
                                      viewedProfile: state.currentCard!.profile,
                                      onBack: () => Navigator.of(context).pop(),
                                      bottomActions: SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          child: DiscoveryActionButtons(
                                            onPass: () {
                                              Navigator.of(context).pop();
                                              ref
                                                  .read(
                                                    discoveryControllerProvider
                                                        .notifier,
                                                  )
                                                  .swipeLeft();
                                            },
                                            onLike: () {
                                              Navigator.of(context).pop();
                                              ref
                                                  .read(
                                                    discoveryControllerProvider
                                                        .notifier,
                                                  )
                                                  .swipeRight();
                                            },
                                            onSuperLike: () {
                                              Navigator.of(context).pop();
                                              ref
                                                  .read(
                                                    discoveryControllerProvider
                                                        .notifier,
                                                  )
                                                  .swipeUp();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 150),
                              child: state.isLoading
                                  ? const Center(
                                      child: MatchLoadingIndicator(
                                        type: MatchLoadingType.thinking,
                                        message:
                                            'curating intentional profiles...',
                                      ),
                                    )
                                  : _buildEmptyState(context, ref, isDark),
                            ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: hasPhoto
                                    ? Colors.transparent
                                    : const Color(0xFF263A32),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: DiscoveryHeader(
                                  onSearch: () async {
                                    final profile =
                                        await showSearch<ProfileEntity?>(
                                          context: context,
                                          delegate: PeopleSearch(
                                            state.cards
                                                .map((card) => card.profile)
                                                .toList(),
                                          ),
                                        );
                                    if (profile == null || !context.mounted) {
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MotionTokens.editorialPageRoute(
                                        page: ProfileDetailScreen(
                                          isMyProfile: false,
                                          viewedProfile: profile,
                                          onBack: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    );
                                  },
                                  profile: myProfile,
                                  todaysPicks: state.isTodaysPicksMode,
                                  onToggleFeed: () => ref
                                      .read(
                                        discoveryControllerProvider.notifier,
                                      )
                                      .toggleFeedMode(),
                                  onRewind:
                                      state.currentIndex > 0 && !state.isLoading
                                      ? () => ref
                                            .read(
                                              discoveryControllerProvider
                                                  .notifier,
                                            )
                                            .rewind()
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const MatchText(
              'nothing here yet.',
              style: MatchTextStyle.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'your next conversation could start tomorrow. we deliberately curate profiles to prevent mindless swiping.',
              style: AppTypography.bodyMedium(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            MatchButton(
              text: 'curate again',
              isFullWidth: false,
              variant: MatchButtonVariant.outline,
              onPressed: () {
                ref.read(discoveryControllerProvider.notifier).loadFeed();
              },
            ),
          ],
        ),
      ),
    );
  }
}
