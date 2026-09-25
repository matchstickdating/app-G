/// Community Interest Group / Lounge Entity
class CommunityGroupEntity {
  final String id;
  final String name;
  final String topic;
  final String description;
  final String coverImageUrl;
  final int memberCount;
  final String iconName;

  const CommunityGroupEntity({
    required this.id,
    required this.name,
    required this.topic,
    required this.description,
    required this.coverImageUrl,
    required this.memberCount,
    required this.iconName,
  });
}
