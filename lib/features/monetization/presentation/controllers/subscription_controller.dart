import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionState {
  final bool isLoading;
  final bool isPurchasing;
  final SubscriptionEntity? subscription;
  final String selectedPlanId;
  final String? errorMessage;
  final String? successMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.isPurchasing = false,
    this.subscription,
    this.selectedPlanId = 'studio_annual',
    this.errorMessage,
    this.successMessage,
  });

  bool get isStudioMember => subscription?.isStudio ?? false;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPurchasing,
    SubscriptionEntity? subscription,
    String? selectedPlanId,
    String? errorMessage,
    String? successMessage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      subscription: subscription ?? this.subscription,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl();
});

class SubscriptionController extends Notifier<SubscriptionState> {
  SubscriptionRepository get _repo => ref.read(subscriptionRepositoryProvider);

  @override
  SubscriptionState build() {
    return const SubscriptionState();
  }

  Future<void> loadSubscription(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final sub = await _repo.getSubscription(userId);
      state = state.copyWith(isLoading: false, subscription: sub);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectPlan(String planId) {
    state = state.copyWith(selectedPlanId: planId);
  }

  Future<bool> purchaseCurrentPlan(String userId) async {
    state = state.copyWith(isPurchasing: true, errorMessage: null, successMessage: null);
    try {
      final sub = await _repo.purchasePlan(
        userId: userId,
        planId: state.selectedPlanId,
      );
      state = state.copyWith(
        isPurchasing: false,
        subscription: sub,
        successMessage: 'welcome to match stick studio.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'could not complete purchase. please try again.',
      );
      return false;
    }
  }

  Future<void> restore(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final sub = await _repo.restorePurchases(userId);
      state = state.copyWith(
        isLoading: false,
        subscription: sub,
        successMessage: 'purchases restored successfully.',
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(SubscriptionController.new);
