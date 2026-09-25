import 'dart:async';
import '../../../../core/network/supabase_service.dart';
import '../../../matching/domain/entities/match_entity.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Map<String, StreamController<MessageEntity>> _streamControllers = {};

  final Map<String, List<MessageEntity>> _mockMessages = {
    'match-user-marcus': [
      MessageEntity(
        id: 'msg-1',
        matchId: 'match-user-marcus',
        senderId: 'user-marcus',
        content: 'hey ananya. saw your note on vintage paperbacks. found anything memorable lately?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
        isRead: true,
      ),
      MessageEntity(
        id: 'msg-2',
        matchId: 'match-user-marcus',
        senderId: 'demo-user-1',
        content: 'found a 1974 print of calvino\'s invisible cities last weekend. how was your sunday?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
      MessageEntity(
        id: 'msg-3',
        matchId: 'match-user-marcus',
        senderId: 'user-marcus',
        content: 'invisible cities is incredible. you definitely have the best taste in town.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: false,
      ),
    ],
  };

  final List<MatchEntity> _mockMatches = [
    MatchEntity(
      id: 'match-user-marcus',
      user1Id: 'demo-user-1',
      user2Id: 'user-marcus',
      otherProfile: ProfileEntity(
        id: 'user-marcus',
        displayName: 'Marcus',
        birthdate: DateTime(1998, 9, 21),
        gender: 'man',
        genderPreference: const ['woman'],
        relationshipGoal: 'long_term',
        bio: 'sketching Brutalist facades by day, listening to ambient vinyl by night.',
        locationCity: 'Tokyo',
        locationCountry: 'Japan',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'm1',
            url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        interests: const ['architecture', 'vinyl records', 'specialty coffee'],
        createdAt: DateTime.now(),
      ),
      compatibilityScore: 92,
      compatibilityReasons: const ['shared interest in architecture', 'ambient vinyl lovers'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      lastMessageSnippet: 'invisible cities is incredible. you definitely have...',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 8)),
      hasUnreadMessages: true,
    ),
    MatchEntity(
      id: 'match-user-sofia',
      user1Id: 'demo-user-1',
      user2Id: 'user-sofia',
      otherProfile: ProfileEntity(
        id: 'user-sofia',
        displayName: 'Sofia',
        birthdate: DateTime(1999, 1, 15),
        gender: 'woman',
        genderPreference: const ['man'],
        relationshipGoal: 'serious',
        bio: 'contemporary sculpture, late dinners, and 35mm street photography.',
        locationCity: 'Berlin',
        locationCountry: 'Germany',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 's1',
            url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        interests: const ['contemporary art', 'film & cinema'],
        createdAt: DateTime.now(),
      ),
      compatibilityScore: 89,
      compatibilityReasons: const ['shared love of cinema & contemporary art'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      lastMessageSnippet: null,
      lastMessageAt: null,
      hasUnreadMessages: false,
    ),
  ];

  @override
  Future<List<MatchEntity>> getMatches(String userId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('matches')
            .select('*, user1:user1_id(display_name, birthdate, profile_photos(*)), user2:user2_id(display_name, birthdate, profile_photos(*))')
            .or('user1_id.eq.$userId,user2_id.eq.$userId')
            .eq('is_active', true)
            .order('created_at', ascending: false);

        if (res.isNotEmpty) {
          // Parse live matches
        }
      } catch (_) {}
    }
    return List.from(_mockMatches);
  }

  @override
  Future<List<MessageEntity>> getMessages(String matchId) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('messages')
            .select('*')
            .eq('match_id', matchId)
            .order('created_at', ascending: true);

        if (res.isNotEmpty) {
          return (res as List)
              .map((m) => MessageEntity(
                    id: m['id'],
                    matchId: m['match_id'],
                    senderId: m['sender_id'],
                    content: m['content'],
                    mediaUrl: m['media_url'],
                    mediaType: m['media_type'] ?? 'text',
                    isRead: m['is_read'] ?? false,
                    createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
                  ))
              .toList();
        }
      } catch (_) {}
    }
    return List.from(_mockMessages[matchId] ?? []);
  }

  @override
  Future<MessageEntity> sendMessage({
    required String matchId,
    required String senderId,
    required String content,
    String? mediaUrl,
    String mediaType = 'text',
  }) async {
    final newMsg = MessageEntity(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      senderId: senderId,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      isRead: false,
      createdAt: DateTime.now(),
    );

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('messages').insert({
          'match_id': matchId,
          'sender_id': senderId,
          'content': content,
          'media_url': mediaUrl,
          'media_type': mediaType,
        });
      } catch (_) {}
    }

    _mockMessages.putIfAbsent(matchId, () => []).add(newMsg);
    _streamControllers[matchId]?.add(newMsg);

    return newMsg;
  }

  @override
  Future<void> addReaction({
    required String messageId,
    required String userId,
    required String reaction,
  }) async {
    // Save reaction
  }

  @override
  Future<void> markAsRead(String matchId, String currentUserId) async {
    final list = _mockMessages[matchId];
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].senderId != currentUserId) {
          list[i] = MessageEntity(
            id: list[i].id,
            matchId: list[i].matchId,
            senderId: list[i].senderId,
            content: list[i].content,
            mediaUrl: list[i].mediaUrl,
            mediaType: list[i].mediaType,
            isRead: true,
            createdAt: list[i].createdAt,
            reactions: list[i].reactions,
          );
        }
      }
    }
  }

  @override
  Future<void> unmatch(String matchId) async {
    _mockMatches.removeWhere((m) => m.id == matchId);
    _mockMessages.remove(matchId);
  }

  @override
  Future<void> blockUser(String blockerId, String blockedId) async {
    _mockMatches.removeWhere((m) => m.user1Id == blockedId || m.user2Id == blockedId);
  }

  @override
  Stream<MessageEntity> subscribeToMessages(String matchId) {
    _streamControllers.putIfAbsent(matchId, () => StreamController<MessageEntity>.broadcast());
    return _streamControllers[matchId]!.stream;
  }
}
