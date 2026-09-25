import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileState {
  final ProfileEntity? profile;
  final int completeness;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profile,
    this.completeness = 85,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    int? completeness,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      completeness: completeness ?? this.completeness,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

class ProfileController extends Notifier<ProfileState> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileState build() {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.userId ?? 'demo-user-1';
    Future.microtask(() => loadProfile(userId));
    return const ProfileState(isLoading: true);
  }

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repository.getProfile(userId);
      final score = await _repository.calculateCompleteness(profile);
      state = state.copyWith(
        profile: profile,
        completeness: score,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'could not load profile.',
      );
    }
  }

  Future<void> updateBio(String bio) async {
    if (state.profile == null) return;
    final updated = ProfileEntity(
      id: state.profile!.id,
      displayName: state.profile!.displayName,
      birthdate: state.profile!.birthdate,
      gender: state.profile!.gender,
      genderPreference: state.profile!.genderPreference,
      relationshipGoal: state.profile!.relationshipGoal,
      bio: bio,
      locationCity: state.profile!.locationCity,
      locationCountry: state.profile!.locationCountry,
      isVerified: state.profile!.isVerified,
      isProfileComplete: state.profile!.isProfileComplete,
      photos: state.profile!.photos,
      prompts: state.profile!.prompts,
      interests: state.profile!.interests,
      createdAt: state.profile!.createdAt,
    );
    await _repository.updateProfile(updated);
    final score = await _repository.calculateCompleteness(updated);
    state = state.copyWith(profile: updated, completeness: score);
  }

  Future<void> updateLocation(String city, String country) async {
    if (state.profile == null) return;
    final updated = ProfileEntity(
      id: state.profile!.id,
      displayName: state.profile!.displayName,
      birthdate: state.profile!.birthdate,
      gender: state.profile!.gender,
      genderPreference: state.profile!.genderPreference,
      relationshipGoal: state.profile!.relationshipGoal,
      bio: state.profile!.bio,
      locationCity: city,
      locationCountry: country,
      isVerified: state.profile!.isVerified,
      isProfileComplete: state.profile!.isProfileComplete,
      photos: state.profile!.photos,
      prompts: state.profile!.prompts,
      interests: state.profile!.interests,
      createdAt: state.profile!.createdAt,
    );
    await _repository.updateProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> updateRelationshipGoal(String goal) async {
    if (state.profile == null) return;
    final updated = ProfileEntity(
      id: state.profile!.id,
      displayName: state.profile!.displayName,
      birthdate: state.profile!.birthdate,
      gender: state.profile!.gender,
      genderPreference: state.profile!.genderPreference,
      relationshipGoal: goal,
      bio: state.profile!.bio,
      locationCity: state.profile!.locationCity,
      locationCountry: state.profile!.locationCountry,
      isVerified: state.profile!.isVerified,
      isProfileComplete: state.profile!.isProfileComplete,
      photos: state.profile!.photos,
      prompts: state.profile!.prompts,
      interests: state.profile!.interests,
      createdAt: state.profile!.createdAt,
    );
    await _repository.updateProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> addPhoto(String url) async {
    if (state.profile == null) return;
    await _repository.addPhoto(state.profile!.id, url);
    await loadProfile(state.profile!.id);
  }

  Future<void> removePhoto(String photoId) async {
    if (state.profile == null) return;
    await _repository.removePhoto(photoId);
    await loadProfile(state.profile!.id);
  }

  Future<void> updatePrompt(String promptId, String question, String answer) async {
    if (state.profile == null) return;
    await _repository.updatePrompt(state.profile!.id, promptId, question, answer);
    await loadProfile(state.profile!.id);
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
