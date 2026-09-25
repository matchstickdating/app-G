import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';

/// Mutual Match Entity (Domain Layer)
class MatchEntity {
  final String id;
  final String user1Id;
  final String user2Id;
  final ProfileEntity otherProfile;
  final int compatibilityScore;
  final List<String> compatibilityReasons;
  final DateTime createdAt;
  final String? lastMessageSnippet;
  final DateTime? lastMessageAt;
  final bool hasUnreadMessages;

  const MatchEntity({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.otherProfile,
    this.compatibilityScore = 85,
    this.compatibilityReasons = const [],
    required this.createdAt,
    this.lastMessageSnippet,
    this.lastMessageAt,
    this.hasUnreadMessages = false,
  });
}
