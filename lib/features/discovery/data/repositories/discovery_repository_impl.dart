import '../../../../core/network/supabase_service.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/discovery_card_entity.dart';
import '../../domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final List<DiscoveryCardEntity> _fallbackCards = [
    DiscoveryCardEntity(
      profile: ProfileEntity(
        id: 'user-marcus',
        displayName: 'Marcus',
        birthdate: DateTime(1998, 9, 21),
        gender: 'man',
        genderPreference: const ['woman'],
        relationshipGoal: 'long_term',
        bio: 'sketching Brutalist facades by day, listening to ambient vinyl by night.',
        locationCity: 'Tokyo',
        locationCountry: 'Japan',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'm-1',
            url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
          ProfilePhotoEntity(
            id: 'm-2',
            url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800',
            orderIndex: 1,
          ),
        ],
        prompts: const [
          ProfilePromptEntity(
            id: 'mp-1',
            question: 'my perfect sunday is...',
            answer: 'exploring modern architecture, hunting for obscure records, and espresso in Yanaka.',
            orderIndex: 0,
          ),
          ProfilePromptEntity(
            id: 'mp-2',
            question: 'my green flag is...',
            answer: 'remembering the obscure track you played in the car three weeks ago.',
            orderIndex: 1,
          ),
        ],
        interests: const ['architecture', 'vinyl records', 'specialty coffee', 'minimalism'],
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      compatibilityScore: 92,
      compatibilityReasons: const [
        'shared interest in architecture & vinyl',
        'similar long-term relationship intention',
        'both enjoy quiet Sunday mornings',
      ],
      distanceKm: 4.2,
    ),
    DiscoveryCardEntity(
      profile: ProfileEntity(
        id: 'user-sofia',
        displayName: 'Sofia',
        birthdate: DateTime(1999, 1, 15),
        gender: 'woman',
        genderPreference: const ['man'],
        relationshipGoal: 'serious',
        bio: 'contemporary sculpture, late dinners, and 35mm street photography.',
        locationCity: 'Berlin',
        locationCountry: 'Germany',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 's-1',
            url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
          ProfilePhotoEntity(
            id: 's-2',
            url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
            orderIndex: 1,
          ),
        ],
        prompts: const [
          ProfilePromptEntity(
            id: 'sp-1',
            question: 'we\'ll get along if...',
            answer: 'you can look at a blank canvas for ten minutes and find something new to talk about.',
            orderIndex: 0,
          ),
        ],
        interests: const ['contemporary art', 'film & cinema', 'natural wine', 'street photography'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      compatibilityScore: 89,
      compatibilityReasons: const [
        'shared love of cinema & contemporary art',
        'both value intentional conversation',
      ],
      distanceKm: 6.8,
    ),
    DiscoveryCardEntity(
      profile: ProfileEntity(
        id: 'user-leo',
        displayName: 'Leo',
        birthdate: DateTime(1997, 6, 8),
        gender: 'man',
        genderPreference: const ['woman'],
        relationshipGoal: 'serious',
        bio: 'industrial designer, pour-over enthusiast, analog synth collector.',
        locationCity: 'Milan',
        locationCountry: 'Italy',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'l-1',
            url: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        prompts: const [
          ProfilePromptEntity(
            id: 'lp-1',
            question: 'a random thing about me...',
            answer: 'i can distinguish three different roasts blindly by aroma alone.',
            orderIndex: 0,
          ),
        ],
        interests: const ['specialty coffee', 'minimalism', 'night walks', 'live jazz'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      compatibilityScore: 86,
      compatibilityReasons: const [
        'both value specialty coffee culture',
        'shared passion for design & minimalism',
      ],
      distanceKm: 8.5,
    ),
    DiscoveryCardEntity(
      profile: ProfileEntity(
        id: 'user-elena',
        displayName: 'Elena',
        birthdate: DateTime(2001, 11, 30),
        gender: 'woman',
        genderPreference: const ['man'],
        relationshipGoal: 'long_term',
        bio: 'documentary filmmaker and book collector. usually found somewhere quiet.',
        locationCity: 'Paris',
        locationCountry: 'France',
        isVerified: true,
        photos: const [
          ProfilePhotoEntity(
            id: 'e-1',
            url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
            orderIndex: 0,
            isPrimary: true,
          ),
        ],
        prompts: const [
          ProfilePromptEntity(
            id: 'ep-1',
            question: 'my perfect sunday is...',
            answer: 'reading French new-wave screenplays in a small garden café.',
            orderIndex: 0,
          ),
        ],
        interests: const ['literature', 'film & cinema', 'tea ceremonies', 'architecture'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      compatibilityScore: 94,
      compatibilityReasons: const [
        'mutual devotion to literature & cinema',
        'aligned long-term relationship mindset',
      ],
      distanceKm: 12.0,
    ),
  ];

  @override
  Future<List<DiscoveryCardEntity>> getDiscoveryFeed({
    required String currentUserId,
    int limit = 15,
  }) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('profiles')
            .select('*, profile_photos(*), profile_prompts(*)')
            .neq('id', currentUserId)
            .limit(limit);

        if (res.isNotEmpty) {
          return (res as List).map((row) {
            final photos = (row['profile_photos'] as List? ?? [])
                .map((p) => ProfilePhotoEntity(
                      id: p['id'],
                      url: p['url'],
                      orderIndex: p['order_index'] ?? 0,
                      isPrimary: p['is_primary'] ?? false,
                    ))
                .toList();

            final prompts = (row['profile_prompts'] as List? ?? [])
                .map((p) => ProfilePromptEntity(
                      id: p['id'],
                      question: p['prompt_question'],
                      answer: p['prompt_answer'],
                      orderIndex: p['order_index'] ?? 0,
                    ))
                .toList();

            final profile = ProfileEntity(
              id: row['id'],
              displayName: row['display_name'] ?? 'Someone',
              birthdate: DateTime.tryParse(row['birthdate'] ?? '') ?? DateTime(2000, 1, 1),
              gender: row['gender'] ?? 'other',
              genderPreference: List<String>.from(row['gender_preference'] ?? []),
              relationshipGoal: row['relationship_goal'] ?? 'serious',
              bio: row['bio'],
              locationCity: row['location_city'],
              locationCountry: row['location_country'],
              isVerified: row['is_verified'] ?? false,
              photos: photos,
              prompts: prompts,
              interests: ['specialty coffee', 'film & cinema', 'vinyl records'],
              createdAt: DateTime.tryParse(row['created_at'] ?? '') ?? DateTime.now(),
            );

            return DiscoveryCardEntity(
              profile: profile,
              compatibilityScore: 88,
              compatibilityReasons: const [
                'shared interest in specialty coffee',
                'aligned intentional dating goals',
              ],
              distanceKm: 5.4,
            );
          }).toList();
        }
      } catch (_) {
        // Fall back to fixtures
      }
    }

    return List.from(_fallbackCards);
  }

  @override
  Future<List<DiscoveryCardEntity>> getTodaysPicks({
    required String currentUserId,
  }) async {
    final feed = await getDiscoveryFeed(currentUserId: currentUserId, limit: 5);
    return feed.take(3).toList();
  }

  @override
  Future<bool> sendReaction({
    required String fromUserId,
    required String toUserId,
    required String reaction,
  }) async {
    if (reaction == 'like' || reaction == 'super_like') {
      if (SupabaseService.isInitialized && SupabaseService.client != null) {
        try {
          await SupabaseService.client!.from('likes').insert({
            'from_user_id': fromUserId,
            'to_user_id': toUserId,
            'is_super_like': reaction == 'super_like',
          });
        } catch (_) {}
      }
      // For Marcus: simulate mutual match celebration!
      if (toUserId == 'user-marcus' || toUserId.contains('11111111')) {
        return true; // Is a mutual match!
      }
    }
    return false; // Not a mutual match yet
  }
}
