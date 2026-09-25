/// Subscription & Entitlements Domain Entities
enum SubscriptionTier {
  free,
  studio,
}

class SubscriptionEntity {
  final String userId;
  final SubscriptionTier tier;
  final String planId; // 'free', 'studio_monthly', 'studio_annual'
  final String planName;
  final String status; // 'active', 'free', 'past_due', 'canceled'
  final DateTime? expiresAt;
  final bool canSeeWhoLiked;
  final bool unlimitedRewinds;
  final bool priorityAi;
  final bool customDatePlanner;

  const SubscriptionEntity({
    required this.userId,
    this.tier = SubscriptionTier.free,
    this.planId = 'free',
    this.planName = 'Match Stick Standard',
    this.status = 'free',
    this.expiresAt,
    this.canSeeWhoLiked = false,
    this.unlimitedRewinds = false,
    this.priorityAi = false,
    this.customDatePlanner = false,
  });

  bool get isStudio => tier == SubscriptionTier.studio && status == 'active';
}
