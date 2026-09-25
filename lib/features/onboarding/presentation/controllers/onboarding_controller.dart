import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/supabase_service.dart';
import 'package:matchstick/features/auth/presentation/controllers/auth_controller.dart';

class OnboardingState {
  final int currentStep;
  final String displayName;
  final DateTime? birthdate;
  final String gender;
  final String relationshipGoal;
  final List<String> genderPreference;
  final String locationCity;
  final String locationCountry;
  final List<String> interests;
  final List<String> photos;
  final List<Map<String, String>> prompts; // [{'question': '...', 'answer': '...'}]
  final String bio;
  final bool isLoading;

  const OnboardingState({
    this.currentStep = 0,
    this.displayName = '',
    this.birthdate,
    this.gender = 'woman',
    this.relationshipGoal = 'serious',
    this.genderPreference = const ['man'],
    this.locationCity = 'Chennai',
    this.locationCountry = 'India',
    this.interests = const ['specialty coffee', 'film & cinema'],
    this.photos = const [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    ],
    this.prompts = const [
      {
        'question': 'my perfect sunday is...',
        'answer': 'an early pour-over, a long walk without headphones, and vintage paperbacks.'
      }
    ],
    this.bio = 'hunting for the quietest corner and the darkest roast.',
    this.isLoading = false,
  });

  bool get canProceed {
    switch (currentStep) {
      case 0:
        return displayName.trim().length >= 2 && birthdate != null;
      case 1:
        return relationshipGoal.isNotEmpty;
      case 2:
        return genderPreference.isNotEmpty;
      case 3:
        return locationCity.trim().isNotEmpty;
      case 4:
        return interests.length >= 3;
      case 5:
        return photos.isNotEmpty;
      case 6:
        return prompts.isNotEmpty && prompts.every((p) => (p['answer'] ?? '').trim().isNotEmpty);
      default:
        return true;
    }
  }

  OnboardingState copyWith({
    int? currentStep,
    String? displayName,
    DateTime? birthdate,
    String? gender,
    String? relationshipGoal,
    List<String>? genderPreference,
    String? locationCity,
    String? locationCountry,
    List<String>? interests,
    List<String>? photos,
    List<Map<String, String>>? prompts,
    String? bio,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      displayName: displayName ?? this.displayName,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      genderPreference: genderPreference ?? this.genderPreference,
      locationCity: locationCity ?? this.locationCity,
      locationCountry: locationCountry ?? this.locationCountry,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      prompts: prompts ?? this.prompts,
      bio: bio ?? this.bio,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState(birthdate: DateTime(2000, 1, 1));
  }

  void setDisplayName(String name) => state = state.copyWith(displayName: name);
  void setBirthdate(DateTime date) => state = state.copyWith(birthdate: date);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setRelationshipGoal(String goal) => state = state.copyWith(relationshipGoal: goal);

  void toggleGenderPreference(String pref) {
    final list = List<String>.from(state.genderPreference);
    if (list.contains(pref)) {
      if (list.length > 1) list.remove(pref);
    } else {
      list.add(pref);
    }
    state = state.copyWith(genderPreference: list);
  }

  void setLocation(String city, String country) {
    state = state.copyWith(locationCity: city, locationCountry: country);
  }

  void toggleInterest(String interest) {
    final list = List<String>.from(state.interests);
    if (list.contains(interest)) {
      list.remove(interest);
    } else {
      list.add(interest);
    }
    state = state.copyWith(interests: list);
  }

  void addPhoto(String url) {
    final list = List<String>.from(state.photos)..add(url);
    state = state.copyWith(photos: list);
  }

  void removePhoto(int index) {
    final list = List<String>.from(state.photos)..removeAt(index);
    state = state.copyWith(photos: list);
  }

  void replacePhoto(int index, String url) {
    if (index >= 0 && index < state.photos.length) {
      final list = List<String>.from(state.photos);
      list[index] = url;
      state = state.copyWith(photos: list);
    }
  }

  void setBio(String bio) => state = state.copyWith(bio: bio);

  void updatePrompt(int index, String question, String answer) {
    final list = List<Map<String, String>>.from(state.prompts);
    if (index < list.length) {
      list[index] = {'question': question, 'answer': answer};
    } else {
      list.add({'question': question, 'answer': answer});
    }
    state = state.copyWith(prompts: list);
  }

  void addPrompt(String question, String answer) {
    final list = List<Map<String, String>>.from(state.prompts)
      ..add({'question': question, 'answer': answer});
    state = state.copyWith(prompts: list);
  }

  void nextStep() {
    if (state.currentStep < 6) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<bool> finishOnboarding() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = ref.read(authControllerProvider);
      final currentAuthUser = SupabaseService.client?.auth.currentUser;
      final userId = currentAuthUser?.id ?? authState.userId ?? 'demo-user-id';

      // Persist to Supabase if initialized and user is authenticated
      if (SupabaseService.isInitialized && SupabaseService.client != null && currentAuthUser != null) {
        try {
          final birthdateStr = (state.birthdate ?? DateTime(1998, 1, 1)).toIso8601String().split('T')[0];
          await SupabaseService.client!.from('profiles').upsert({
            'id': userId,
            'display_name': state.displayName.isNotEmpty ? state.displayName : 'New Member',
            'birthdate': birthdateStr,
            'gender': state.gender,
            'gender_preference': state.genderPreference,
            'relationship_goal': state.relationshipGoal,
            'bio': state.bio,
            'location_city': state.locationCity,
            'location_country': state.locationCountry,
            'is_profile_complete': true,
          }).timeout(const Duration(seconds: 4));

          // Insert photos (clean replace)
          await SupabaseService.client!.from('profile_photos').delete().eq('user_id', userId).timeout(const Duration(seconds: 3));
          for (int i = 0; i < state.photos.length; i++) {
            await SupabaseService.client!.from('profile_photos').insert({
              'user_id': userId,
              'url': state.photos[i],
              'order_index': i,
              'is_primary': i == 0,
            }).timeout(const Duration(seconds: 3));
          }

          // Insert prompts (clean replace)
          await SupabaseService.client!.from('profile_prompts').delete().eq('user_id', userId).timeout(const Duration(seconds: 3));
          for (int i = 0; i < state.prompts.length; i++) {
            await SupabaseService.client!.from('profile_prompts').insert({
              'user_id': userId,
              'prompt_question': state.prompts[i]['question'] ?? '',
              'prompt_answer': state.prompts[i]['answer'] ?? '',
              'order_index': i,
            }).timeout(const Duration(seconds: 3));
          }
        } catch (_) {
          // Non-fatal if remote persistence times out or fails in preview
        }
      }

      // Mark onboarding complete in auth controller & local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('matchstick_onboarding_complete_$userId', true);
      await ref.read(authControllerProvider.notifier).completeOnboarding();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      try {
        final authState = ref.read(authControllerProvider);
        final currentAuthUser = SupabaseService.client?.auth.currentUser;
        final userId = currentAuthUser?.id ?? authState.userId ?? 'demo-user-id';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('matchstick_onboarding_complete_$userId', true);
        await ref.read(authControllerProvider.notifier).completeOnboarding();
      } catch (_) {}
      return true;
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
