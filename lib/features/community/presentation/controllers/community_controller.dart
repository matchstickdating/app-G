import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../domain/entities/community_group_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/repositories/community_repository.dart';

class CommunityState {
  final bool isLoading;
  final List<CommunityGroupEntity> groups;
  final String selectedGroupId;
  final List<CommunityPostEntity> posts;
  final bool isSubmittingPost;

  const CommunityState({
    this.isLoading = false,
    this.groups = const [],
    this.selectedGroupId = 'group-vinyl',
    this.posts = const [],
    this.isSubmittingPost = false,
  });

  CommunityGroupEntity? get selectedGroup =>
      groups.where((g) => g.id == selectedGroupId).firstOrNull;

  CommunityState copyWith({
    bool? isLoading,
    List<CommunityGroupEntity>? groups,
    String? selectedGroupId,
    List<CommunityPostEntity>? posts,
    bool? isSubmittingPost,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      groups: groups ?? this.groups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      posts: posts ?? this.posts,
      isSubmittingPost: isSubmittingPost ?? this.isSubmittingPost,
    );
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl();
});

class CommunityController extends Notifier<CommunityState> {
  CommunityRepository get _repo => ref.read(communityRepositoryProvider);

  @override
  CommunityState build() {
    Future.microtask(() => init());
    return const CommunityState(isLoading: true);
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final groups = await _repo.getGroups();
    final defaultGroupId = groups.isNotEmpty ? groups.first.id : 'group-vinyl';
    final posts = await _repo.getPostsByGroup(defaultGroupId);
    state = state.copyWith(
      isLoading: false,
      groups: groups,
      selectedGroupId: defaultGroupId,
      posts: posts,
    );
  }

  Future<void> selectGroup(String groupId) async {
    if (state.selectedGroupId == groupId) return;
    state = state.copyWith(selectedGroupId: groupId, isLoading: true);
    final posts = await _repo.getPostsByGroup(groupId);
    state = state.copyWith(isLoading: false, posts: posts);
  }

  Future<void> toggleLike(String postId) async {
    await _repo.toggleLike(postId);
    final updated = await _repo.getPostsByGroup(state.selectedGroupId);
    state = state.copyWith(posts: updated);
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required bool isAuthorVerified,
    required String content,
  }) async {
    state = state.copyWith(isSubmittingPost: true);
    await _repo.createPost(
      groupId: state.selectedGroupId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAuthorVerified: isAuthorVerified,
      content: content,
    );
    final updated = await _repo.getPostsByGroup(state.selectedGroupId);
    state = state.copyWith(isSubmittingPost: false, posts: updated);
  }

  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required String content,
  }) async {
    await _repo.addComment(
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
    );
    final updated = await _repo.getPostsByGroup(state.selectedGroupId);
    state = state.copyWith(posts: updated);
  }
}

final communityControllerProvider =
    NotifierProvider<CommunityController, CommunityState>(CommunityController.new);
