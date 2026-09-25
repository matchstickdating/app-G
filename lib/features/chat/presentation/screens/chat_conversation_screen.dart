import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_avatar.dart';
import '../../../../core/widgets/match_bottom_sheet.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../ai/presentation/controllers/ai_controller.dart';
import '../../../ai/presentation/screens/match_coach_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../date_planner/presentation/screens/date_ideas_screen.dart';
import '../../../date_planner/presentation/screens/date_planner_screen.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/profile_detail_screen.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String matchId;
  final ProfileEntity partnerProfile;

  const ChatConversationScreen({
    super.key,
    required this.matchId,
    required this.partnerProfile,
  });

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider.notifier).openConversation(widget.matchId);
      final myProfile = ref.read(profileControllerProvider).profile;
      ref.read(aiControllerProvider.notifier).fetchStarters(
            partnerName: widget.partnerProfile.displayName,
            myInterests: myProfile?.interests ?? ['design', 'coffee', 'literature'],
            partnerInterests: widget.partnerProfile.interests,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openMatchCoach() {
    Navigator.of(context).push(
      MotionTokens.editorialPageRoute(
        page: MatchCoachScreen(partnerName: widget.partnerProfile.displayName),
      ),
    );
  }

  void _openDatePlanner() {
    Navigator.of(context).push(
      MotionTokens.editorialPageRoute(
        page: DatePlannerScreen(
          partnerName: widget.partnerProfile.displayName,
          matchId: widget.matchId,
          onShareToChat: (planText) {
            ref.read(chatControllerProvider.notifier).sendMessage(widget.matchId, planText);
            _scrollToBottom();
          },
        ),
      ),
    );
  }

  void _openDateIdeas() {
    Navigator.of(context).push(
      MotionTokens.editorialPageRoute(
        page: DateIdeasScreen(
          partnerName: widget.partnerProfile.displayName,
          onShareToChat: (ideaText) {
            ref.read(chatControllerProvider.notifier).sendMessage(widget.matchId, ideaText);
            _scrollToBottom();
          },
        ),
      ),
    );
  }

  void _showAiAssistant() {
    final partner = widget.partnerProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiState = ref.read(aiControllerProvider);

    MatchBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'ai conversation assistant',
                  style: AppTypography.headingSmall(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'contextual prompts derived authentic to your shared interests.',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Quick Tool Shortcuts
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MatchChip(
                      label: '✦ match coach',
                      isSelected: false,
                      onSelected: () {
                        Navigator.of(context).pop();
                        _openMatchCoach();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MatchChip(
                      label: '✦ plan a date',
                      isSelected: false,
                      onSelected: () {
                        Navigator.of(context).pop();
                        _openDatePlanner();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MatchChip(
                      label: '✦ date ideas',
                      isSelected: false,
                      onSelected: () {
                        Navigator.of(context).pop();
                        _openDateIdeas();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Starter Suggestions
            Text(
              'suggested conversation starters',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            if (aiState.starters.isNotEmpty) ...[
              ...aiState.starters.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildAiSuggestionTile(
                      s.tone ?? 'thoughtful',
                      s.suggestionText,
                      isDark,
                    ),
                  )),
            ] else ...[
              _buildAiSuggestionTile(
                'you both appreciate ${partner.interests.firstOrNull ?? "intentional design"}.',
                '"what\'s the most inspiring place or space you\'ve explored lately?"',
                isDark,
              ),
              const SizedBox(height: 10),
              _buildAiSuggestionTile(
                'playful reply',
                '"okay, important question: who gets control of the playlist on a road trip?"',
                isDark,
              ),
              const SizedBox(height: 10),
              _buildAiSuggestionTile(
                'thoughtful question',
                '"saw your note on quiet Sundays. what\'s your ideal morning routine look like?"',
                isDark,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSuggestionTile(String title, String suggestion, bool isDark) {
    return MatchCard(
      onTap: () {
        Navigator.of(context).pop();
        ref.read(chatControllerProvider.notifier).sendMessage(
              widget.matchId,
              suggestion.replaceAll('"', ''),
            );
        _scrollToBottom();
      },
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toLowerCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: -0.01 * 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    final partner = widget.partnerProfile;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: AppColors.accent),
                title: const Text('✦ match coach'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openMatchCoach();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined, color: AppColors.accent),
                title: const Text('✦ plan a date with ai'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openDatePlanner();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline, color: AppColors.accent),
                title: const Text('✦ curated date ideas'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openDateIdeas();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('view profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MotionTokens.editorialPageRoute(
                      page: Scaffold(
                        appBar: AppBar(title: Text(partner.displayName.toLowerCase())),
                        body: const ProfileDetailScreen(isMyProfile: false),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_off),
                title: const Text('unmatch'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(chatControllerProvider.notifier).unmatch(widget.matchId);
                  if (!mounted) return;
                  MatchToast.show(this.context, message: 'unmatched with ${partner.displayName.toLowerCase()}.');
                  Navigator.of(this.context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: AppColors.error),
                title: const Text('block user', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(chatControllerProvider.notifier).block(partner.id);
                  if (!mounted) return;
                  MatchToast.show(this.context, message: '${partner.displayName.toLowerCase()} has been blocked.');
                  Navigator.of(this.context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final messages = chatState.getMessages(widget.matchId);
    final currentUserId = ref.watch(authControllerProvider).userId ?? 'demo-user-1';
    final partner = widget.partnerProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            MatchAvatar(
              name: partner.displayName,
              imageUrl: partner.primaryPhotoUrl,
              size: MatchAvatarSize.small,
              isVerified: partner.isVerified,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.displayName.toLowerCase(),
                  style: AppTypography.headingSmall().copyWith(fontSize: 16),
                ),
                Text(
                  'active now',
                  style: AppTypography.caption(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ai dating assistant',
            icon: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
            onPressed: _showAiAssistant,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Thread
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MatchAvatar(
                            name: partner.displayName,
                            imageUrl: partner.primaryPhotoUrl,
                            size: MatchAvatarSize.hero,
                            isVerified: partner.isVerified,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'you matched with ${partner.displayName.toLowerCase()}.',
                            style: AppTypography.headingSmall(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'break the ice with something genuine.',
                            style: AppTypography.caption(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MatchButton(
                            text: '✦ get ai starter',
                            variant: MatchButtonVariant.outline,
                            isFullWidth: false,
                            size: MatchButtonSize.compact,
                            onPressed: _showAiAssistant,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        message: msg,
                        isSentByMe: msg.isSentByMe(currentUserId),
                      );
                    },
                  ),
          ),

          // Chat Input Bar
          ChatInputBar(
            onSendMessage: (text) {
              ref.read(chatControllerProvider.notifier).sendMessage(widget.matchId, text);
              _scrollToBottom();
            },
            onAiAssist: _showAiAssistant,
          ),
        ],
      ),
    );
  }
}
