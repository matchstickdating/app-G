import '../../../../core/network/supabase_service.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionEntity? _cachedSubscription;

  @override
  Future<SubscriptionEntity> getSubscription(String userId) async {
    if (_cachedSubscription != null) {
      return _cachedSubscription!;
    }

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('subscriptions')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (res != null) {
          final isStudio = res['tier'] == 'studio' && res['status'] == 'active';
          _cachedSubscription = SubscriptionEntity(
            userId: userId,
            tier: isStudio ? SubscriptionTier.studio : SubscriptionTier.free,
            planId: res['plan_id'] ?? 'free',
            planName: isStudio ? 'Match Stick Studio' : 'Match Stick Standard',
            status: res['status'] ?? 'free',
            expiresAt: res['expires_at'] != null ? DateTime.parse(res['expires_at']) : null,
            canSeeWhoLiked: isStudio,
            unlimitedRewinds: isStudio,
            priorityAi: isStudio,
            customDatePlanner: isStudio,
          );
          return _cachedSubscription!;
        }
      } catch (_) {}
    }

    _cachedSubscription = SubscriptionEntity(userId: userId);
    return _cachedSubscription!;
  }

  @override
  Future<SubscriptionEntity> purchasePlan({
    required String userId,
    required String planId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final isAnnual = planId.contains('annual');
    final expiry = DateTime.now().add(Duration(days: isAnnual ? 365 : 30));

    final sub = SubscriptionEntity(
      userId: userId,
      tier: SubscriptionTier.studio,
      planId: planId,
      planName: 'Match Stick Studio',
      status: 'active',
      expiresAt: expiry,
      canSeeWhoLiked: true,
      unlimitedRewinds: true,
      priorityAi: true,
      customDatePlanner: true,
    );

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('subscriptions').upsert({
          'user_id': userId,
          'tier': 'studio',
          'plan_id': planId,
          'status': 'active',
          'expires_at': expiry.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    _cachedSubscription = sub;
    return sub;
  }

  @override
  Future<SubscriptionEntity> restorePurchases(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getSubscription(userId);
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    _cachedSubscription = SubscriptionEntity(userId: userId);
  }
}
