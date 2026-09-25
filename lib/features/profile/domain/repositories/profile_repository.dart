import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> addPhoto(String userId, String url, {bool isPrimary = false});
  Future<void> removePhoto(String photoId);
  Future<void> reorderPhotos(String userId, List<String> photoIds);
  Future<void> updatePrompt(String userId, String promptId, String question, String answer);
  Future<int> calculateCompleteness(ProfileEntity profile);
}
