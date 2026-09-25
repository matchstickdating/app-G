import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionEntity> getSubscription(String userId);
  Future<SubscriptionEntity> purchasePlan({
    required String userId,
    required String planId,
  });
  Future<SubscriptionEntity> restorePurchases(String userId);
  Future<void> cancelSubscription(String userId);
}
