/// Date Plan Entity (Domain Layer)
class DatePlanEntity {
  final String id;
  final String createdBy;
  final String? matchId;
  final String title;
  final String city;
  final String budgetTier; // '$', '$$', '$$$'
  final String vibe; // 'cozy', 'adventurous', 'chill', 'romantic'
  final List<DatePlanStopEntity> itinerary;
  final String status; // 'draft', 'shared', 'accepted', 'completed'
  final DateTime createdAt;

  const DatePlanEntity({
    required this.id,
    required this.createdBy,
    this.matchId,
    required this.title,
    required this.city,
    required this.budgetTier,
    required this.vibe,
    required this.itinerary,
    this.status = 'draft',
    required this.createdAt,
  });
}

class DatePlanStopEntity {
  final String time; // e.g. "5:30 PM"
  final String title; // e.g. "artisan coffee & conversation"
  final String description; // e.g. "quiet corner booth at Blue Bottle"
  final String venueType; // 'cafe', 'walk', 'restaurant', 'bar', 'dessert'

  const DatePlanStopEntity({
    required this.time,
    required this.title,
    required this.description,
    required this.venueType,
  });
}
