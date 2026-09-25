import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_avatar.dart';
import '../../../../core/widgets/match_bottom_sheet.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_chip.dart';
import '../../../../core/widgets/match_loading_indicator.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/community_controller.dart';
import '../../domain/entities/community_post_entity.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  final Map<String, bool> _expandedComments = {};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _showNewPostModal(BuildContext context) {
    final contentController = TextEditingController();

    MatchBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const MatchText('share with lounge', style: MatchTextStyle.headingSmall),
            const SizedBox(height: 6),
            Text(
              'post a genuine curiosity, recommend a space, or share an authentic thought.',
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 18),
            MatchTextField(
              controller: contentController,
              hintText: 'what is inspiring you lately?',
              maxLines: 4,
              maxLength: 280,
            ),
            const SizedBox(height: 18),
            MatchButton(
              text: 'post to lounge',
              variant: MatchButtonVariant.primary,
              onPressed: () async {
                final text = contentController.text.trim();
                if (text.isEmpty) return;

                final authState = ref.read(authControllerProvider);
                final profileState = ref.read(profileControllerProvider);
                final myProfile = profileState.profile;

                await ref.read(communityControllerProvider.notifier).createPost(
                      authorId: authState.userId ?? 'current-user',
                      authorName: myProfile?.displayName ?? 'You',
                      authorAvatarUrl: myProfile?.primaryPhotoUrl,
                      isAuthorVerified: myProfile?.isVerified ?? false,
                      content: text,
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  MatchToast.show(context, message: 'posted to lounge.');
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final group = communityState.selectedGroup;

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'interest lounges',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, size: 22),
            onPressed: () => _showNewPostModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Lounges Selector Carousel
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: communityState.groups.map((g) {
                    final isSelected = g.id == communityState.selectedGroupId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MatchChip(
                        label: g.name.toLowerCase(),
                        isSelected: isSelected,
                        onSelected: () {
                          ref.read(communityControllerProvider.notifier).selectGroup(g.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Active Lounge Header Card
            if (group != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: MatchCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.network(
                          group.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.forum_outlined, size: 20, color: AppColors.accent),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name.toLowerCase(),
                              style: AppTypography.headingSmall().copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              group.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${group.memberCount} members',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Posts Feed
            Expanded(
              child: communityState.isLoading
                  ? const Center(
                      child: MatchLoadingIndicator(
                        type: MatchLoadingType.pulse,
                        message: 'loading lounge discussions...',
                      ),
                    )
                  : communityState.posts.isEmpty
                      ? Center(
                          child: Text(
                            'no posts yet in this lounge.\nbe the first to share something.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: communityState.posts.length,
                          itemBuilder: (context, index) {
                            final post = communityState.posts[index];
                            return _buildPostCard(context, post, isDark);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPostEntity post, bool isDark) {
    final areCommentsOpen = _expandedComments[post.id] ?? false;

    if (!_commentControllers.containsKey(post.id)) {
      _commentControllers[post.id] = TextEditingController();
    }
    final commentController = _commentControllers[post.id]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MatchCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Row
            Row(
              children: [
                MatchAvatar(
                  name: post.authorName,
                  imageUrl: post.authorAvatarUrl,
                  size: MatchAvatarSize.small,
                  isVerified: post.isAuthorVerified,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName.toLowerCase(),
                        style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'recently',
                        style: AppTypography.caption(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Content
            Text(
              post.content,
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ).copyWith(height: 1.4),
            ),
            const SizedBox(height: 16),

            // Interaction Bar
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ref.read(communityControllerProvider.notifier).toggleLike(post.id);
                  },
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.isLikedByMe ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: post.isLikedByMe ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedComments[post.id] = !areCommentsOpen;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Comments Section (Expandable)
            if (areCommentsOpen) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Existing Comments
              ...post.comments.map((comment) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${comment.authorName.toLowerCase()}: ',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        Expanded(
                          child: Text(
                            comment.content,
                            style: AppTypography.caption(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              // Add Comment Field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: AppTypography.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: 'add a reply...',
                        hintStyle: AppTypography.caption(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, size: 18, color: AppColors.accent),
                    onPressed: () {
                      final text = commentController.text.trim();
                      if (text.isEmpty) return;

                      final myProfile = ref.read(profileControllerProvider).profile;
                      final authState = ref.read(authControllerProvider);

                      ref.read(communityControllerProvider.notifier).addComment(
                            postId: post.id,
                            authorId: authState.userId ?? 'current-user',
                            authorName: myProfile?.displayName ?? 'You',
                            authorAvatarUrl: myProfile?.primaryPhotoUrl,
                            content: text,
                          );

                      commentController.clear();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
