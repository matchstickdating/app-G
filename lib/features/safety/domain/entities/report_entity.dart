/// Report Entity (Domain Layer)
class ReportEntity {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String reportedUserName;
  final String reason; // 'harassment', 'impersonation', 'scam', 'inappropriate_media', 'offline_safety'
  final String details;
  final String status; // 'pending', 'reviewing', 'resolved', 'dismissed'
  final DateTime createdAt;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });
}
