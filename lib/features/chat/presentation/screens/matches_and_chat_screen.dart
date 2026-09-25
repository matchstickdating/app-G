import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_avatar.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../controllers/chat_controller.dart';
import 'chat_conversation_screen.dart';

class MatchesAndChatScreen extends ConsumerWidget {
  const MatchesAndChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (chatState.isLoading) {
      return const Scaffold(
        body: Center(
          child: MatchLoadingIndicator(
            type: MatchLoadingType.thinking,
            message: 'loading conversations...',
          ),
        ),
      );
    }

    final matches = chatState.matches;
    final newMatches = matches.where((m) => m.lastMessageSnippet == null).toList();
    final activeConversations = matches.where((m) => m.lastMessageSnippet != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'messages',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: matches.isEmpty
            ? _buildEmptyState(isDark)
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // New Matches Carousel
                  if (newMatches.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'new matches (${newMatches.length})',
                        style: AppTypography.caption(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 104,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: newMatches.length,
                        itemBuilder: (context, index) {
                          final match = newMatches[index];
                          final partner = match.otherProfile;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MotionTokens.editorialPageRoute(
                                    page: ChatConversationScreen(
                                      matchId: match.id,
                                      partnerProfile: partner,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MatchAvatar(
                                    name: partner.displayName,
                                    imageUrl: partner.primaryPhotoUrl,
                                    size: MatchAvatarSize.large,
                                    isVerified: partner.isVerified,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    partner.displayName.toLowerCase(),
                                    style: AppTypography.caption(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ).copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Active Conversations Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'conversations',
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Conversations List
                  ...activeConversations.map((match) {
                    final partner = match.otherProfile;
                    final timeStr = match.lastMessageAt != null
                        ? DateFormat('h:mm a').format(match.lastMessageAt!).toLowerCase()
                        : '';

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MotionTokens.editorialPageRoute(
                            page: ChatConversationScreen(
                              matchId: match.id,
                              partnerProfile: partner,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          children: [
                            MatchAvatar(
                              name: partner.displayName,
                              imageUrl: partner.primaryPhotoUrl,
                              size: MatchAvatarSize.medium,
                              isVerified: partner.isVerified,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        partner.displayName.toLowerCase(),
                                        style: AppTypography.bodyLarge(
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ).copyWith(
                                          fontWeight: match.hasUnreadMessages
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: AppTypography.caption(
                                          color: isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    match.lastMessageSnippet ?? 'say hello...',
                                    style: AppTypography.bodyMedium(
                                      color: match.hasUnreadMessages
                                          ? (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary)
                                          : (isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary),
                                    ).copyWith(
                                      fontWeight: match.hasUnreadMessages
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (match.hasUnreadMessages) ...[
                              const SizedBox(width: 10),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.lightTextTertiary),
            const SizedBox(height: 20),
            const MatchText(
              'nothing here yet.',
              style: MatchTextStyle.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'your next conversation could start tomorrow. match with someone from discovery to start chatting.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
