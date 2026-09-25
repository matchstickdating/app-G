import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../matching/domain/entities/match_entity.dart';

class ChatState {
  final List<MatchEntity> matches;
  final Map<String, List<MessageEntity>> messagesByMatch;
  final bool isLoading;
  final bool isPartnerTyping;

  const ChatState({
    this.matches = const [],
    this.messagesByMatch = const {},
    this.isLoading = false,
    this.isPartnerTyping = false,
  });

  List<MessageEntity> getMessages(String matchId) => messagesByMatch[matchId] ?? [];

  ChatState copyWith({
    List<MatchEntity>? matches,
    Map<String, List<MessageEntity>>? messagesByMatch,
    bool? isLoading,
    bool? isPartnerTyping,
  }) {
    return ChatState(
      matches: matches ?? this.matches,
      messagesByMatch: messagesByMatch ?? this.messagesByMatch,
      isLoading: isLoading ?? this.isLoading,
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
    );
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

class ChatController extends Notifier<ChatState> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);
  StreamSubscription<MessageEntity>? _msgSubscription;

  @override
  ChatState build() {
    Future.microtask(loadMatches);
    ref.onDispose(() {
      _msgSubscription?.cancel();
    });
    return const ChatState(isLoading: true);
  }

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true);
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    final list = await _repository.getMatches(userId);
    state = state.copyWith(matches: list, isLoading: false);
  }

  Future<void> openConversation(String matchId) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    // Load messages
    final msgs = await _repository.getMessages(matchId);
    final map = Map<String, List<MessageEntity>>.from(state.messagesByMatch);
    map[matchId] = msgs;
    state = state.copyWith(messagesByMatch: map);

    await _repository.markAsRead(matchId, userId);

    // Subscribe to new messages
    await _msgSubscription?.cancel();
    _msgSubscription = _repository.subscribeToMessages(matchId).listen((newMsg) {
      final currentList = List<MessageEntity>.from(state.messagesByMatch[matchId] ?? []);
      if (!currentList.any((m) => m.id == newMsg.id)) {
        currentList.add(newMsg);
        final updatedMap = Map<String, List<MessageEntity>>.from(state.messagesByMatch);
        updatedMap[matchId] = currentList;
        state = state.copyWith(messagesByMatch: updatedMap);
      }
    });
  }

  Future<void> sendMessage(String matchId, String content, {String? mediaUrl}) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';

    final sentMsg = await _repository.sendMessage(
      matchId: matchId,
      senderId: userId,
      content: content,
      mediaUrl: mediaUrl,
    );

    final currentList = List<MessageEntity>.from(state.messagesByMatch[matchId] ?? []);
    if (!currentList.any((m) => m.id == sentMsg.id)) {
      currentList.add(sentMsg);
      final updatedMap = Map<String, List<MessageEntity>>.from(state.messagesByMatch);
      updatedMap[matchId] = currentList;
      state = state.copyWith(messagesByMatch: updatedMap);
    }
  }

  Future<void> unmatch(String matchId) async {
    await _repository.unmatch(matchId);
    final updatedMatches = state.matches.where((m) => m.id != matchId).toList();
    final updatedMap = Map<String, List<MessageEntity>>.from(state.messagesByMatch)..remove(matchId);
    state = state.copyWith(matches: updatedMatches, messagesByMatch: updatedMap);
  }

  Future<void> block(String targetUserId) async {
    final authState = ref.read(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';
    await _repository.blockUser(userId, targetUserId);
    await loadMatches();
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);
