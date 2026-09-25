import 'package:uuid/uuid.dart';
import '../../../../core/network/supabase_service.dart';
import '../../domain/entities/community_group_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final _uuid = const Uuid();

  final List<CommunityGroupEntity> _groups = const [
    CommunityGroupEntity(
      id: 'group-vinyl',
      name: 'analog vinyl & hi-fi',
      topic: 'music & sound',
      description: 'for lovers of warm turntable acoustics, rare wax digging, and listening bars.',
      coverImageUrl: 'https://images.unsplash.com/photo-1539185441755-769473a23570?w=800',
      memberCount: 842,
      iconName: 'album',
    ),
    CommunityGroupEntity(
      id: 'group-coffee',
      name: 'specialty coffee & quiet reads',
      topic: 'lifestyle',
      description: 'single-origin pour-overs, independent paperbacks, and quiet morning corners.',
      coverImageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      memberCount: 1420,
      iconName: 'local_cafe',
    ),
    CommunityGroupEntity(
      id: 'group-film',
      name: '35mm & medium format',
      topic: 'photography',
      description: 'grain, light leaks, darkrooms, and documenting everyday urban life on film.',
      coverImageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
      memberCount: 960,
      iconName: 'camera_alt',
    ),
    CommunityGroupEntity(
      id: 'group-architecture',
      name: 'modernist & brutalist design',
      topic: 'design & space',
      description: 'form follows function. concrete textures, bauhaus lines, and intentional spaces.',
      coverImageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
      memberCount: 680,
      iconName: 'apartment',
    ),
  ];

  late final Map<String, List<CommunityPostEntity>> _postsByGroup = {
    'group-vinyl': [
      CommunityPostEntity(
        id: 'post-1',
        groupId: 'group-vinyl',
        authorId: 'user-elena',
        authorName: 'Elena Rostova',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        isAuthorVerified: true,
        content: 'found an original 1978 pressing of Casiopea\'s self-titled LP at a basement stall today. pristine condition. what\'s your white whale record right now?',
        likeCount: 24,
        commentCount: 4,
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        comments: [
          CommunityCommentEntity(
            id: 'comm-1',
            authorId: 'user-julian',
            authorName: 'Julian Thorne',
            content: 'Incredible find! Mine has to be Hiroshi Yoshimura\'s Green.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          CommunityCommentEntity(
            id: 'comm-2',
            authorId: 'user-maya',
            authorName: 'Maya Lin',
            content: 'Japanese city pop on vinyl hits so differently.',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      CommunityPostEntity(
        id: 'post-2',
        groupId: 'group-vinyl',
        authorId: 'user-julian',
        authorName: 'Julian Thorne',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        isAuthorVerified: true,
        content: 'hosting a small vinyl listening session this thursday evening. low intervention orange wine and acoustic jazz. anyone in the area welcome.',
        likeCount: 18,
        commentCount: 2,
        isLikedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        comments: [],
      ),
    ],
    'group-coffee': [
      CommunityPostEntity(
        id: 'post-3',
        groupId: 'group-coffee',
        authorId: 'user-maya',
        authorName: 'Maya Lin',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
        isAuthorVerified: true,
        content: 'tried an Ethiopian natural process with notes of bergamot and wild jasmine this morning. paired with Haruki Murakami\'s essays. quiet bliss.',
        likeCount: 31,
        commentCount: 3,
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        comments: [],
      ),
    ],
    'group-film': [
      CommunityPostEntity(
        id: 'post-4',
        groupId: 'group-film',
        authorId: 'user-mateo',
        authorName: 'Mateo Rossi',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
        isAuthorVerified: false,
        content: 'pushed Portra 400 to 1600 on an evening street walk. the shadows have this unmistakable golden haze that digital sensors just cannot recreate.',
        likeCount: 42,
        commentCount: 5,
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        comments: [],
      ),
    ],
    'group-architecture': [
      CommunityPostEntity(
        id: 'post-5',
        groupId: 'group-architecture',
        authorId: 'user-elena',
        authorName: 'Elena Rostova',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        isAuthorVerified: true,
        content: 'spent three hours sketching the concrete skylights at the municipal library today. light behaves like liquid in well-designed space.',
        likeCount: 28,
        commentCount: 2,
        isLikedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        comments: [],
      ),
    ],
  };

  @override
  Future<List<CommunityGroupEntity>> getGroups() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _groups;
  }

  @override
  Future<List<CommunityPostEntity>> getPostsByGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_postsByGroup[groupId] ?? []);
  }

  @override
  Future<CommunityPostEntity> createPost({
    required String groupId,
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required bool isAuthorVerified,
    required String content,
    String? photoUrl,
  }) async {
    final post = CommunityPostEntity(
      id: _uuid.v4(),
      groupId: groupId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      isAuthorVerified: isAuthorVerified,
      content: content,
      photoUrl: photoUrl,
      likeCount: 0,
      commentCount: 0,
      isLikedByMe: false,
      createdAt: DateTime.now(),
    );

    if (_postsByGroup[groupId] == null) {
      _postsByGroup[groupId] = [];
    }
    _postsByGroup[groupId]!.insert(0, post);

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('community_posts').insert({
          'id': post.id,
          'group_id': groupId,
          'author_id': authorId,
          'content': content,
          'photo_url': photoUrl,
          'created_at': post.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }

    return post;
  }

  @override
  Future<void> toggleLike(String postId) async {
    for (final list in _postsByGroup.values) {
      final index = list.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final current = list[index];
        final newLiked = !current.isLikedByMe;
        final newCount = newLiked ? current.likeCount + 1 : (current.likeCount - 1).clamp(0, 9999);
        list[index] = current.copyWith(
          isLikedByMe: newLiked,
          likeCount: newCount,
        );
        break;
      }
    }
  }

  @override
  Future<CommunityCommentEntity> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String? authorAvatarUrl,
    required String content,
  }) async {
    final comment = CommunityCommentEntity(
      id: _uuid.v4(),
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    for (final list in _postsByGroup.values) {
      final index = list.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final current = list[index];
        final updatedComments = List<CommunityCommentEntity>.from(current.comments)..add(comment);
        list[index] = current.copyWith(
          comments: updatedComments,
          commentCount: current.commentCount + 1,
        );
        break;
      }
    }

    return comment;
  }
}
