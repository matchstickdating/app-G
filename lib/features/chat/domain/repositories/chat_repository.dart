import 'package:matchstick/features/matching/domain/entities/match_entity.dart';
import 'package:matchstick/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<MatchEntity>> getMatches(String userId);
  Future<List<MessageEntity>> getMessages(String matchId);
  Future<MessageEntity> sendMessage({
    required String matchId,
    required String senderId,
    required String content,
    String? mediaUrl,
    String mediaType = 'text',
  });
  Future<void> addReaction({
    required String messageId,
    required String userId,
    required String reaction,
  });
  Future<void> markAsRead(String matchId, String currentUserId);
  Future<void> unmatch(String matchId);
  Future<void> blockUser(String blockerId, String blockedId);
  Stream<MessageEntity> subscribeToMessages(String matchId);
}
