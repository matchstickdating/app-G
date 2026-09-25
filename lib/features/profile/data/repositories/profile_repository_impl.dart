import '../../../../core/network/supabase_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  // In-memory cache & fallback fixtures
  ProfileEntity? _cachedProfile;

  ProfileEntity _getFallbackProfile(String userId) {
    return ProfileEntity(
      id: userId,
      displayName: 'Ananya',
      birthdate: DateTime(2000, 4, 12),
      gender: 'woman',
      genderPreference: const ['man'],
      relationshipGoal: 'serious',
      bio: 'hunting for the quietest corner and the darkest roast. typography nerd, gallery hopper.',
      locationCity: 'Chennai',
      locationCountry: 'India',
      isVerified: true,
      isProfileComplete: true,
      photos: const [
        ProfilePhotoEntity(
          id: 'photo-1',
          url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
          orderIndex: 0,
          isPrimary: true,
        ),
        ProfilePhotoEntity(
          id: 'photo-2',
          url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
          orderIndex: 1,
          isPrimary: false,
        ),
        ProfilePhotoEntity(
          id: 'photo-3',
          url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
          orderIndex: 2,
          isPrimary: false,
        ),
      ],
      prompts: const [
        ProfilePromptEntity(
          id: 'prompt-1',
          question: 'my perfect sunday is...',
          answer: 'an early pour-over, a long walk without headphones, and browsing vintage paperbacks.',
          orderIndex: 0,
        ),
        ProfilePromptEntity(
          id: 'prompt-2',
          question: 'we\'ll get along if...',
          answer: 'you can argue passionately about movie soundtracks or font kerning.',
          orderIndex: 1,
        ),
      ],
      interests: const [
        'specialty coffee',
        'film & cinema',
        'architecture',
        'vinyl records',
        'night walks',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    if (_cachedProfile != null && _cachedProfile!.id == userId) {
      return _cachedProfile!;
    }

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final profileRes = await SupabaseService.client!
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();

        if (profileRes != null) {
          final photosRes = await SupabaseService.client!
              .from('profile_photos')
              .select('*')
              .eq('user_id', userId)
              .order('order_index');

          final promptsRes = await SupabaseService.client!
              .from('profile_prompts')
              .select('*')
              .eq('user_id', userId)
              .order('order_index');

          final photos = (photosRes as List)
              .map((p) => ProfilePhotoEntity(
                    id: p['id'],
                    url: p['url'],
                    orderIndex: p['order_index'] ?? 0,
                    isPrimary: p['is_primary'] ?? false,
                  ))
              .toList();

          final prompts = (promptsRes as List)
              .map((p) => ProfilePromptEntity(
                    id: p['id'],
                    question: p['prompt_question'],
                    answer: p['prompt_answer'],
                    orderIndex: p['order_index'] ?? 0,
                  ))
              .toList();

          _cachedProfile = ProfileEntity(
            id: profileRes['id'],
            displayName: profileRes['display_name'] ?? 'Anonymous',
            birthdate: DateTime.tryParse(profileRes['birthdate'] ?? '') ?? DateTime(2000, 1, 1),
            gender: profileRes['gender'] ?? 'other',
            genderPreference: List<String>.from(profileRes['gender_preference'] ?? []),
            relationshipGoal: profileRes['relationship_goal'] ?? 'serious',
            bio: profileRes['bio'],
            locationCity: profileRes['location_city'],
            locationCountry: profileRes['location_country'],
            latitude: (profileRes['latitude'] as num?)?.toDouble(),
            longitude: (profileRes['longitude'] as num?)?.toDouble(),
            isVerified: profileRes['is_verified'] ?? false,
            isProfileComplete: profileRes['is_profile_complete'] ?? false,
            photos: photos,
            prompts: prompts,
            interests: ['specialty coffee', 'film & cinema', 'vinyl records'],
            createdAt: DateTime.tryParse(profileRes['created_at'] ?? '') ?? DateTime.now(),
          );
          return _cachedProfile!;
        }
      } catch (_) {
        // Fall back to fixture
      }
    }

    _cachedProfile = _getFallbackProfile(userId);
    return _cachedProfile!;
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    _cachedProfile = profile;
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      await SupabaseService.client!.from('profiles').update({
        'display_name': profile.displayName,
        'bio': profile.bio,
        'location_city': profile.locationCity,
        'location_country': profile.locationCountry,
        'relationship_goal': profile.relationshipGoal,
      }).eq('id', profile.id);
    }
  }

  @override
  Future<void> addPhoto(String userId, String url, {bool isPrimary = false}) async {
    final current = await getProfile(userId);
    final updatedPhotos = List<ProfilePhotoEntity>.from(current.photos)
      ..add(
        ProfilePhotoEntity(
          id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
          url: url,
          orderIndex: current.photos.length,
          isPrimary: isPrimary,
        ),
      );
    _cachedProfile = ProfileEntity(
      id: current.id,
      displayName: current.displayName,
      birthdate: current.birthdate,
      gender: current.gender,
      genderPreference: current.genderPreference,
      relationshipGoal: current.relationshipGoal,
      bio: current.bio,
      locationCity: current.locationCity,
      locationCountry: current.locationCountry,
      isVerified: current.isVerified,
      isProfileComplete: current.isProfileComplete,
      photos: updatedPhotos,
      prompts: current.prompts,
      interests: current.interests,
      createdAt: current.createdAt,
    );
  }

  @override
  Future<void> removePhoto(String photoId) async {
    if (_cachedProfile != null) {
      final updatedPhotos = _cachedProfile!.photos.where((p) => p.id != photoId).toList();
      _cachedProfile = ProfileEntity(
        id: _cachedProfile!.id,
        displayName: _cachedProfile!.displayName,
        birthdate: _cachedProfile!.birthdate,
        gender: _cachedProfile!.gender,
        genderPreference: _cachedProfile!.genderPreference,
        relationshipGoal: _cachedProfile!.relationshipGoal,
        bio: _cachedProfile!.bio,
        locationCity: _cachedProfile!.locationCity,
        locationCountry: _cachedProfile!.locationCountry,
        isVerified: _cachedProfile!.isVerified,
        isProfileComplete: _cachedProfile!.isProfileComplete,
        photos: updatedPhotos,
        prompts: _cachedProfile!.prompts,
        interests: _cachedProfile!.interests,
        createdAt: _cachedProfile!.createdAt,
      );
    }
  }

  @override
  Future<void> reorderPhotos(String userId, List<String> photoIds) async {
    // reorder cache
  }

  @override
  Future<void> updatePrompt(String userId, String promptId, String question, String answer) async {
    final current = await getProfile(userId);
    final updatedPrompts = current.prompts.map((p) {
      if (p.id == promptId) {
        return ProfilePromptEntity(
          id: p.id,
          question: question,
          answer: answer,
          orderIndex: p.orderIndex,
        );
      }
      return p;
    }).toList();

    _cachedProfile = ProfileEntity(
      id: current.id,
      displayName: current.displayName,
      birthdate: current.birthdate,
      gender: current.gender,
      genderPreference: current.genderPreference,
      relationshipGoal: current.relationshipGoal,
      bio: current.bio,
      locationCity: current.locationCity,
      locationCountry: current.locationCountry,
      isVerified: current.isVerified,
      isProfileComplete: current.isProfileComplete,
      photos: current.photos,
      prompts: updatedPrompts,
      interests: current.interests,
      createdAt: current.createdAt,
    );
  }

  @override
  Future<int> calculateCompleteness(ProfileEntity profile) async {
    int score = 0;
    if (profile.displayName.isNotEmpty) score += 15;
    if (profile.photos.length >= 2) score += 30;
    if (profile.prompts.isNotEmpty) score += 25;
    if (profile.bio != null && profile.bio!.isNotEmpty) score += 15;
    if (profile.interests.length >= 3) score += 15;
    return score.clamp(0, 100);
  }
}
