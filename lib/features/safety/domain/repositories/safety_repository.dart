import '../entities/report_entity.dart';
import '../entities/verification_entity.dart';

abstract class SafetyRepository {
  Future<void> submitReport(ReportEntity report);
  Future<VerificationEntity> submitSelfieVerification({
    required String userId,
    required String selfieUrl,
    required String poseType,
  });
  Future<VerificationEntity> getVerificationStatus(String userId);
  Future<void> blockUser({required String userId, required String targetUserId});
  Future<void> unblockUser({required String userId, required String targetUserId});
  Future<List<String>> getBlockedUserIds(String userId);
}
