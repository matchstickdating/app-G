import 'package:flutter/material.dart';
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

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryControllerProvider);
    final myProfile = ref.watch(profileControllerProvider).profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for mutual match detection to trigger celebration modal
    ref.listen(discoveryControllerProvider, (prev, next) {
      if (next.matchedCard != null && prev?.matchedCard != next.matchedCard && myProfile != null) {
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const MatchText(
              'match stick',
              style: MatchTextStyle.caption,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        actions: [
          // Today's Picks Mode Pill Toggle
          GestureDetector(
            onTap: () {
              ref.read(discoveryControllerProvider.notifier).toggleFeedMode();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.isTodaysPicksMode
                    ? (isDark ? const Color(0xFF241515) : const Color(0xFFFFF0F0))
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.isTodaysPicksMode
                      ? AppColors.accent.withValues(alpha: 0.5)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: state.isTodaysPicksMode ? AppColors.accent : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    state.isTodaysPicksMode ? "today's picks" : 'all discovery',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: state.isTodaysPicksMode
                          ? AppColors.accent
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      letterSpacing: -0.01 * 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.isTodaysPicksMode
                      ? 'people we think you\'ll actually like.'
                      : 'intentional discovery.',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ),
            ),

            // Card Stack or Empty State
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: MatchLoadingIndicator(
                        type: MatchLoadingType.thinking,
                        message: 'curating intentional profiles...',
                      ),
                    )
                  : !state.hasMoreCards
                      ? _buildEmptyState(context, ref, isDark)
                      : Stack(
                          children: [
                            // Background Card (peek)
                            if (state.currentIndex + 1 <
                                (state.isTodaysPicksMode ? state.todaysPicks.length : state.cards.length))
                              Positioned.fill(
                                child: Transform.scale(
                                  scale: 0.95,
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: DiscoveryCard(
                                      card: state.isTodaysPicksMode
                                          ? state.todaysPicks[state.currentIndex + 1]
                                          : state.cards[state.currentIndex + 1],
                                      onSwipeRight: () {},
                                      onSwipeLeft: () {},
                                      onSwipeUp: () {},
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              ),

                            // Top Active Card
                            Positioned.fill(
                              child: DiscoveryCard(
                                key: ValueKey(state.currentCard?.profile.id),
                                card: state.currentCard!,
                                onSwipeRight: () {
                                  ref.read(discoveryControllerProvider.notifier).swipeRight();
                                },
                                onSwipeLeft: () {
                                  ref.read(discoveryControllerProvider.notifier).swipeLeft();
                                },
                                onSwipeUp: () {
                                  ref.read(discoveryControllerProvider.notifier).swipeUp();
                                },
                                onTap: () {
                                  // Open full editorial detail
                                  Navigator.of(context).push(
                                    MotionTokens.editorialPageRoute(
                                      page: Scaffold(
                                        appBar: AppBar(
                                          leading: IconButton(
                                            icon: const Icon(Icons.close, size: 20),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ),
                                        body: ProfileDetailScreen(
                                          isMyProfile: false,
                                          onBack: () => Navigator.of(context).pop(),
                                        ),
                                        bottomNavigationBar: SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            child: DiscoveryActionButtons(
                                              onPass: () {
                                                Navigator.of(context).pop();
                                                ref.read(discoveryControllerProvider.notifier).swipeLeft();
                                              },
                                              onLike: () {
                                                Navigator.of(context).pop();
                                                ref.read(discoveryControllerProvider.notifier).swipeRight();
                                              },
                                              onSuperLike: () {
                                                Navigator.of(context).pop();
                                                ref.read(discoveryControllerProvider.notifier).swipeUp();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),

            // Bottom Tactile Actions
            if (state.hasMoreCards && !state.isLoading)
              DiscoveryActionButtons(
                canRewind: state.currentIndex > 0,
                onRewind: () {
                  ref.read(discoveryControllerProvider.notifier).rewind();
                },
                onPass: () {
                  ref.read(discoveryControllerProvider.notifier).swipeLeft();
                },
                onSuperLike: () {
                  ref.read(discoveryControllerProvider.notifier).swipeUp();
                },
                onLike: () {
                  ref.read(discoveryControllerProvider.notifier).swipeRight();
                },
              ),
            const SizedBox(height: 10),
          ],
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, size: 24, color: AppColors.accent),
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
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
