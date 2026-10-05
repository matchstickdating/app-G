import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../chat/presentation/screens/chat_conversation_screen.dart';
import '../../../matching/presentation/widgets/match_celebration_dialog.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/profile_detail_screen.dart';
import '../controllers/discovery_controller.dart';
import '../widgets/discovery_action_buttons.dart';
import '../widgets/discovery_card.dart';
import '../widgets/discovery_header.dart';
import '../widgets/discovery_loading_view.dart';
import '../widgets/people_search.dart';
import '../../../profile/domain/entities/profile_entity.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryControllerProvider);
    final myProfile = ref.watch(profileControllerProvider).profile;

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
        backgroundColor: const Color(0xFF101A1C),
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
                      hasPhoto
                          ? 680 + textExtra * 4
                          : state.isLoading
                          ? 820 + textExtra * 14
                          : 900 + textExtra * 26,
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
                          else if (state.isLoading)
                            const DiscoveryLoadingView()
                          else
                            _buildEmptyState(context, ref, state),
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

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    DiscoveryState state,
  ) {
    final isPicks = state.isTodaysPicksMode;
    final hasSeenProfiles = isPicks
        ? state.todaysPicks.isNotEmpty
        : state.cards.isNotEmpty;
    final title = isPicks
        ? "Today's picks are on their way."
        : hasSeenProfiles
        ? "You've met everyone for now."
        : 'A good connection takes time.';
    final description = isPicks
        ? "We're choosing a few people worth meeting. Check back soon."
        : hasSeenProfiles
        ? 'New faces will appear here as they join. Take a moment to explore the rest of Matchstick.'
        : "We're looking for people who feel right for you. Check back soon for new introductions.";

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF263A32), Color(0xFF101A1C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 178, 28, 118),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DISCOVERY · YOUR PACE',
                style: AppTypography.caption(color: Colors.white70)
                    .copyWith(letterSpacing: 2.2, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 168,
                height: 142,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: _emptyPortrait(
                        const Color(0xFF526F65),
                        Colors.white,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 16,
                      child: _emptyPortrait(
                        const Color(0xFF344E4D),
                        Colors.white70,
                      ),
                    ),
                    Positioned(
                      left: 56,
                      bottom: 0,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1B2929),
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Text(
                  title,
                  style: AppTypography.headingLarge(color: Colors.white)
                      .copyWith(height: 1.07),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  description,
                  style: AppTypography.bodyMedium(color: Colors.white70)
                      .copyWith(height: 1.45),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(discoveryControllerProvider.notifier).loadFeed(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  isPicks ? 'refresh picks' : 'refresh profiles',
                  style: AppTypography.button(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyPortrait(Color background, Color foreground) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(Icons.person_rounded, color: foreground, size: 64),
    );
  }
}
