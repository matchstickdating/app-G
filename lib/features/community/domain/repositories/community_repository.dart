import '../entities/community_group_entity.dart';
import '../entities/community_post_entity.dart';

abstract class CommunityRepository {
  Future<List<CommunityGroupEntity>> getGroups();
  Future<List<CommunityPostEntity>> getPostsByGroup(String groupId);
  Future<CommunityPostEntity> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required bool isAuthorVerified,
    required String content,
    String? photoUrl,
  });
  Future<void> toggleLike(String postId);
  Future<CommunityCommentEntity> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required String content,
  });
}
