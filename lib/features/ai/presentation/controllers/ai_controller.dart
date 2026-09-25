import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_recommendation_entity.dart';
import '../../domain/repositories/ai_repository.dart';

class AiState {
  final bool isGenerating;
  final List<String> polishSuggestions;
  final List<AiSuggestionEntity> starters;
  final Map<String, String> replies;
  final List<Map<String, String>> coachConversation;
  final String? errorMessage;

  const AiState({
    this.isGenerating = false,
    this.polishSuggestions = const [],
    this.starters = const [],
    this.replies = const {},
    this.coachConversation = const [
      {
        'role': 'coach',
        'text': 'hello. i am your match coach. ask me anything about natural conversation starters, moving from chat to a real date, or navigating conversational pauses.'
      }
    ],
    this.errorMessage,
  });

  AiState copyWith({
    bool? isGenerating,
    List<String>? polishSuggestions,
    List<AiSuggestionEntity>? starters,
    Map<String, String>? replies,
    List<Map<String, String>>? coachConversation,
    String? errorMessage,
  }) {
    return AiState(
      isGenerating: isGenerating ?? this.isGenerating,
      polishSuggestions: polishSuggestions ?? this.polishSuggestions,
      starters: starters ?? this.starters,
      replies: replies ?? this.replies,
      coachConversation: coachConversation ?? this.coachConversation,
      errorMessage: errorMessage,
    );
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

class AiController extends Notifier<AiState> {
  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  AiState build() => const AiState();

  Future<List<String>> polishProfile({
    String? bio,
    String? promptQuestion,
    String? promptAnswer,
  }) async {
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final suggestions = await _repository.polishProfile(
        bio: bio,
        promptQuestion: promptQuestion,
        promptAnswer: promptAnswer,
      );
      state = state.copyWith(polishSuggestions: suggestions, isGenerating: false);
      return suggestions;
    } catch (e) {
      state = state.copyWith(isGenerating: false, errorMessage: 'could not polish profile.');
      return [];
    }
  }

  Future<void> fetchStarters({
    required String partnerName,
    required List<String> myInterests,
    required List<String> partnerInterests,
  }) async {
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final list = await _repository.generateStarters(
        partnerName: partnerName,
        myInterests: myInterests,
        partnerInterests: partnerInterests,
      );
      state = state.copyWith(starters: list, isGenerating: false);
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> fetchReplies({
    required List<String> recentMessages,
    required String lastMessage,
  }) async {
    state = state.copyWith(isGenerating: true, errorMessage: null);
    try {
      final map = await _repository.generateReplies(
        recentMessages: recentMessages,
        lastMessage: lastMessage,
      );
      state = state.copyWith(replies: map, isGenerating: false);
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> askCoach(String question, String partnerName) async {
    final updated = List<Map<String, String>>.from(state.coachConversation)
      ..add({'role': 'user', 'text': question});

    state = state.copyWith(coachConversation: updated, isGenerating: true);

    try {
      final response = await _repository.askMatchCoach(
        question: question,
        partnerName: partnerName,
      );
      final withCoach = List<Map<String, String>>.from(updated)
        ..add({'role': 'coach', 'text': response});

      state = state.copyWith(coachConversation: withCoach, isGenerating: false);
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }
}

final aiControllerProvider =
    NotifierProvider<AiController, AiState>(AiController.new);
