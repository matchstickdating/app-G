/// Profile Entity (Domain Layer)
class ProfileEntity {
  final String id;
  final String displayName;
  final DateTime birthdate;
  final String gender;
  final List<String> genderPreference;
  final String relationshipGoal; // 'long_term', 'serious', 'casual', 'new_connections', 'figuring_it_out'
  final String? bio;
  final String? locationCity;
  final String? locationCountry;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isProfileComplete;
  final List<ProfilePhotoEntity> photos;
  final List<ProfilePromptEntity> prompts;
  final List<String> interests;
  final DateTime createdAt;

  const ProfileEntity({
    required this.id,
    required this.displayName,
    required this.birthdate,
    required this.gender,
    required this.genderPreference,
    required this.relationshipGoal,
    this.bio,
    this.locationCity,
    this.locationCountry,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isProfileComplete = false,
    this.photos = const [],
    this.prompts = const [],
    this.interests = const [],
    required this.createdAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  String? get primaryPhotoUrl {
    if (photos.isEmpty) return null;
    final primary = photos.where((p) => p.isPrimary);
    if (primary.isNotEmpty) return primary.first.url;
    return photos.first.url;
  }
}

class ProfilePhotoEntity {
  final String id;
  final String url;
  final int orderIndex;
  final bool isPrimary;

  const ProfilePhotoEntity({
    required this.id,
    required this.url,
    required this.orderIndex,
    this.isPrimary = false,
  });
}

class ProfilePromptEntity {
  final String id;
  final String question;
  final String answer;
  final int orderIndex;

  const ProfilePromptEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.orderIndex,
  });
}
