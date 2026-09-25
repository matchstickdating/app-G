/// Photo Verification Entity (Domain Layer)
class VerificationEntity {
  final String id;
  final String userId;
  final String selfieUrl;
  final String poseType; // 'turn_left', 'smile', 'look_straight'
  final String status; // 'unverified', 'pending', 'verified', 'rejected'
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const VerificationEntity({
    required this.id,
    required this.userId,
    required this.selfieUrl,
    required this.poseType,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
}
