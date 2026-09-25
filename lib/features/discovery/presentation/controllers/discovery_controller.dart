import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/discovery_repository_impl.dart';
import '../../domain/entities/discovery_card_entity.dart';
import '../../domain/repositories/discovery_repository.dart';

class DiscoveryState {
  final List<DiscoveryCardEntity> cards;
  final List<DiscoveryCardEntity> todaysPicks;
  final int currentIndex;
  final bool isTodaysPicksMode;
  final bool isLoading;
  final DiscoveryCardEntity? matchedCard;

  const DiscoveryState({
    this.cards = const [],
    this.todaysPicks = const [],
    this.currentIndex = 0,
    this.isTodaysPicksMode = false,
    this.isLoading = false,
    this.matchedCard,
  });

  DiscoveryCardEntity? get currentCard {
    final activeList = isTodaysPicksMode ? todaysPicks : cards;
    if (currentIndex < activeList.length) {
      return activeList[currentIndex];
    }
    return null;
  }

  bool get hasMoreCards {
    final activeList = isTodaysPicksMode ? todaysPicks : cards;
    return currentIndex < activeList.length;
  }

  DiscoveryState copyWith({
    List<DiscoveryCardEntity>? cards,
    List<DiscoveryCardEntity>? todaysPicks,
    int? currentIndex,
    bool? isTodaysPicksMode,
    bool? isLoading,
    DiscoveryCardEntity? matchedCard,
    bool clearMatch = false,
  }) {
    return DiscoveryState(
      cards: cards ?? this.cards,
      todaysPicks: todaysPicks ?? this.todaysPicks,
      currentIndex: currentIndex ?? this.currentIndex,
      isTodaysPicksMode: isTodaysPicksMode ?? this.isTodaysPicksMode,
      isLoading: isLoading ?? this.isLoading,
      matchedCard: clearMatch ? null : (matchedCard ?? this.matchedCard),
    );
  }
}

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepositoryImpl();
});

class DiscoveryController extends Notifier<DiscoveryState> {
  DiscoveryRepository get _repository => ref.read(discoveryRepositoryProvider);

  @override
  DiscoveryState build() {
    Future.microtask(loadFeed);
    return const DiscoveryState(isLoading: true);
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true);
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    final feed = await _repository.getDiscoveryFeed(currentUserId: userId);
    final picks = await _repository.getTodaysPicks(currentUserId: userId);

    state = state.copyWith(
      cards: feed,
      todaysPicks: picks,
      currentIndex: 0,
      isLoading: false,
    );
  }

  void toggleFeedMode() {
    state = state.copyWith(
      isTodaysPicksMode: !state.isTodaysPicksMode,
      currentIndex: 0,
    );
  }

  Future<bool> swipeRight() async {
    final card = state.currentCard;
    if (card == null) return false;

    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    final isMatch = await _repository.sendReaction(
      fromUserId: userId,
      toUserId: card.profile.id,
      reaction: 'like',
    );

    if (isMatch) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        matchedCard: card,
      );
      return true;
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      return false;
    }
  }

  Future<void> swipeLeft() async {
    final card = state.currentCard;
    if (card == null) return;

    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    await _repository.sendReaction(
      fromUserId: userId,
      toUserId: card.profile.id,
      reaction: 'pass',
    );

    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  Future<bool> swipeUp() async {
    final card = state.currentCard;
    if (card == null) return false;

    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    final isMatch = await _repository.sendReaction(
      fromUserId: userId,
      toUserId: card.profile.id,
      reaction: 'super_like',
    );

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      matchedCard: isMatch ? card : null,
    );
    return isMatch;
  }

  void clearMatch() {
    state = state.copyWith(clearMatch: true);
  }

  void rewind() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }
}

final discoveryControllerProvider =
    NotifierProvider<DiscoveryController, DiscoveryState>(DiscoveryController.new);
