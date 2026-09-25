import 'package:uuid/uuid.dart';
import '../../../../core/network/supabase_service.dart';
import '../../domain/entities/ai_recommendation_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../../date_planner/domain/entities/date_plan_entity.dart';

class AiRepositoryImpl implements AiRepository {
  final _uuid = const Uuid();

  @override
  Future<List<String>> polishProfile({
    String? bio,
    String? promptQuestion,
    String? promptAnswer,
  }) async {
    // If Supabase edge function available, call it
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!.functions.invoke(
          'ai-service',
          body: {
            'action': 'profile_polish',
            'payload': {
              'bio': bio,
              'promptQuestion': promptQuestion,
              'promptAnswer': promptAnswer,
            },
          },
        );
        if (res.data != null && res.data['suggestions'] is List) {
          return List<String>.from(res.data['suggestions']);
        }
      } catch (_) {}
    }

    // Contextual intelligent fallback
    await Future.delayed(const Duration(milliseconds: 650));
    if (bio != null && bio.isNotEmpty) {
      return [
        'always planning my next trip and probably my next meal.',
        'quiet corners, heavy paperbacks, and finding the best espresso in town.',
        'equal parts museum afternoon and late night vinyl hunting.',
      ];
    }

    return [
      'an early pour-over, a long walk without headphones, and vintage paperbacks.',
      'three hours in a quiet bookstore followed by late afternoon natural wine.',
      'waking up before the city gets loud, brewing single-origin, and sketching.',
    ];
  }

  @override
  Future<List<AiSuggestionEntity>> generateStarters({
    required String partnerName,
    required List<String> myInterests,
    required List<String> partnerInterests,
    List<Map<String, String>> partnerPrompts = const [],
  }) async {
    // Find shared interests
    final shared = myInterests.where((i) => partnerInterests.contains(i)).toList();
    final primaryTopic = shared.isNotEmpty
        ? shared.first
        : (partnerInterests.isNotEmpty ? partnerInterests.first : 'good conversations');

    await Future.delayed(const Duration(milliseconds: 500));

    return [
      AiSuggestionEntity(
        id: _uuid.v4(),
        suggestionType: 'starter',
        tone: 'thoughtful',
        suggestionText: 'you also appreciate $primaryTopic. what\'s the most memorable spot you\'ve found lately?',
        createdAt: DateTime.now(),
      ),
      AiSuggestionEntity(
        id: _uuid.v4(),
        suggestionType: 'starter',
        tone: 'playful',
        suggestionText: 'important question: if we\'re curating the playlist, who gets veto power?',
        createdAt: DateTime.now(),
      ),
      AiSuggestionEntity(
        id: _uuid.v4(),
        suggestionType: 'starter',
        tone: 'casual',
        suggestionText: 'noticed your note on quiet Sundays. what does your ideal morning look like?',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Map<String, String>> generateReplies({
    required List<String> recentMessages,
    required String lastMessage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return {
      'playful': 'okay, you have officially won the best taste award for today.',
      'thoughtful': 'i completely agree. there\'s something grounding about having that kind of quiet ritual.',
      'casual': 'that sounds pretty much perfect. where was this again?',
      'flirty': 'i was already intrigued, but now you\'ve definitely got my attention.',
    };
  }

  @override
  Future<String> askMatchCoach({
    required String question,
    required String partnerName,
    String? conversationContext,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final q = question.toLowerCase();

    if (q.contains('date') || q.contains('meet') || q.contains('ask out')) {
      return 'The transition from chat to an in-person date feels most natural when tied to a shared curiosity. Since you both enjoy coffee and quiet spots, try: "i\'ve been meaning to check out that new roastery downtown. want to grab a cup together this weekend?" It\'s low-pressure, specific, and authentic.';
    }

    if (q.contains('stuck') || q.contains('awkward') || q.contains('dry')) {
      return 'When conversation slows down, shift from factual questions ("what do you do?") to sensory or reflective prompts. Ask about a favorite recent experience or something they\'re currently passionate about building or discovering.';
    }

    return 'Keep it light and human. Rather than overthinking the "perfect" line, focus on curiosity about their perspective. Authentic questions about favorite music, local spots, or weekend rituals consistently spark meaningful dialogue.';
  }

  @override
  Future<DatePlanEntity> generateDatePlan({
    required String city,
    required String budgetTier,
    required String vibe,
    required List<String> sharedInterests,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final primaryInterest = sharedInterests.isNotEmpty ? sharedInterests.first : 'specialty coffee';

    return DatePlanEntity(
      id: _uuid.v4(),
      createdBy: 'demo-user-1',
      title: 'an intentional evening in $city',
      city: city,
      budgetTier: budgetTier,
      vibe: vibe,
      itinerary: [
        DatePlanStopEntity(
          time: '5:30 PM',
          title: 'pourover & quiet conversation',
          description: 'meeting at a cozy corner table centered around $primaryInterest.',
          venueType: 'cafe',
        ),
        DatePlanStopEntity(
          time: '6:45 PM',
          title: 'architecture & gallery stroll',
          description: 'a relaxed 40-minute walk through the local historic arts district.',
          venueType: 'walk',
        ),
        DatePlanStopEntity(
          time: '7:45 PM',
          title: 'casual dinner & natural wine',
          description: 'unhurried small plates in an intimate setting with warm ambient lighting.',
          venueType: 'restaurant',
        ),
        DatePlanStopEntity(
          time: '9:15 PM',
          title: 'gelato & night walk',
          description: 'artisanal dessert and a gentle stroll before heading home.',
          venueType: 'dessert',
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Map<String, String>>> getDateIdeas({
    required List<String> sharedInterests,
    String? city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {
        'title': 'vintage book hunting & coffee',
        'desc': 'browsing independent bookstores followed by an unhurried pour-over.',
        'vibe': 'cozy',
      },
      {
        'title': 'sunset architecture walk',
        'desc': 'exploring brutalist and mid-century facades during golden hour.',
        'vibe': 'scenic',
      },
      {
        'title': 'listening bar & natural wine',
        'desc': 'audiophile vinyl sound system with curated low-intervention wines.',
        'vibe': 'intimate',
      },
      {
        'title': 'morning farmers market & pastries',
        'desc': 'tasting sourdough, discovering seasonal fruits, and relaxed park seating.',
        'vibe': 'casual',
      },
    ];
  }
}
