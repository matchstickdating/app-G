/// Message Entity (Domain Layer)
class MessageEntity {
  final String id;
  final String matchId;
  final String senderId;
  final String? content;
  final String? mediaUrl;
  final String mediaType; // 'text', 'image', 'voice', 'date_plan'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, String> reactions; // userId -> reactionEmoji

  const MessageEntity({
    required this.id,
    required this.matchId,
    required this.senderId,
    this.content,
    this.mediaUrl,
    this.mediaType = 'text',
    this.isRead = false,
    required this.createdAt,
    this.reactions = const {},
  });

  bool isSentByMe(String currentUserId) => senderId == currentUserId;
}
