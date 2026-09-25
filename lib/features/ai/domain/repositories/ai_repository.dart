import 'package:matchstick/features/ai/domain/entities/ai_recommendation_entity.dart';
import 'package:matchstick/features/date_planner/domain/entities/date_plan_entity.dart';

abstract class AiRepository {
  /// Enhance raw bio or prompt with witty, authentic, editorial polish
  Future<List<String>> polishProfile({
    String? bio,
    String? promptQuestion,
    String? promptAnswer,
  });

  /// Generate 3-5 authentic conversation starters derived strictly from mutual profile facts
  Future<List<AiSuggestionEntity>> generateStarters({
    required String partnerName,
    required List<String> myInterests,
    required List<String> partnerInterests,
    List<Map<String, String>> partnerPrompts = const [],
  });

  /// Context-aware reply suggestions across 4 tones: playful, thoughtful, casual, flirty
  Future<Map<String, String>> generateReplies({
    required List<String> recentMessages,
    required String lastMessage,
  });

  /// Private empathetic dating coach advice
  Future<String> askMatchCoach({
    required String question,
    required String partnerName,
    String? conversationContext,
  });

  /// Generate chronological date itinerary with budget tier and vibe
  Future<DatePlanEntity> generateDatePlan({
    required String city,
    required String budgetTier,
    required String vibe,
    required List<String> sharedInterests,
  });

  /// Generate curated date ideas based on passions
  Future<List<Map<String, String>>> getDateIdeas({
    required List<String> sharedInterests,
    String? city,
  });
}
