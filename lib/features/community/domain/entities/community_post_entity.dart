/// Community Post & Comment Domain Entities
class CommunityCommentEntity {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  const CommunityCommentEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });
}

class CommunityPostEntity {
  final String id;
  final String groupId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final bool isAuthorVerified;
  final String content;
  final String? photoUrl;
  final int likeCount;
  final int commentCount;
  final bool isLikedByMe;
  final List<CommunityCommentEntity> comments;
  final DateTime createdAt;

  const CommunityPostEntity({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.isAuthorVerified = false,
    required this.content,
    this.photoUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
    this.comments = const [],
    required this.createdAt,
  });

  CommunityPostEntity copyWith({
    int? likeCount,
    int? commentCount,
    bool? isLikedByMe,
    List<CommunityCommentEntity>? comments,
  }) {
    return CommunityPostEntity(
      id: id,
      groupId: groupId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAuthorVerified: isAuthorVerified,
      content: content,
      photoUrl: photoUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      comments: comments ?? this.comments,
      createdAt: createdAt,
    );
  }
}
