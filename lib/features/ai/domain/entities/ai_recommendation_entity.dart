/// AI Suggestion & Assistant Entity (Domain Layer)
class AiSuggestionEntity {
  final String id;
  final String? matchId;
  final String suggestionType; // 'starter', 'reply', 'polish', 'date_idea'
  final String? tone; // 'playful', 'casual', 'thoughtful', 'flirty'
  final String suggestionText;
  final bool isUsed;
  final DateTime createdAt;

  const AiSuggestionEntity({
    required this.id,
    this.matchId,
    required this.suggestionType,
    this.tone,
    required this.suggestionText,
    this.isUsed = false,
    required this.createdAt,
  });
}
