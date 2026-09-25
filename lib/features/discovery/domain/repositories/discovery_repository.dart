import '../entities/discovery_card_entity.dart';

abstract class DiscoveryRepository {
  /// Fetch discovery stack of profiles matching user's preferences
  Future<List<DiscoveryCardEntity>> getDiscoveryFeed({
    required String currentUserId,
    int limit = 15,
  });

  /// Fetch curated "Today's Picks" (5 intentional profiles)
  Future<List<DiscoveryCardEntity>> getTodaysPicks({
    required String currentUserId,
  });

  /// Record a user interaction: 'like', 'pass', 'super_like'
  Future<bool> sendReaction({
    required String fromUserId,
    required String toUserId,
    required String reaction, // 'like', 'pass', 'super_like'
  });
}
