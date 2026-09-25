import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';

/// Discovery Profile Card Entity (Domain Layer)
class DiscoveryCardEntity {
  final ProfileEntity profile;
  final int compatibilityScore;
  final List<String> compatibilityReasons;
  final double? distanceKm;

  const DiscoveryCardEntity({
    required this.profile,
    required this.compatibilityScore,
    this.compatibilityReasons = const [],
    this.distanceKm,
  });
}
