import 'package:uuid/uuid.dart';
import '../../../../core/network/supabase_service.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/verification_entity.dart';
import '../../domain/repositories/safety_repository.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  final _uuid = const Uuid();
  final Set<String> _blockedUserIds = {};
  VerificationEntity? _currentVerification;

  @override
  Future<void> submitReport(ReportEntity report) async {
    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('reports').insert({
          'id': report.id,
          'reporter_id': report.reporterId,
          'reported_user_id': report.reportedUserId,
          'reason': report.reason,
          'details': report.details,
          'status': report.status,
          'created_at': report.createdAt.toIso8601String(),
        });
        return;
      } catch (_) {}
    }

    // Local simulation
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<VerificationEntity> submitSelfieVerification({
    required String userId,
    required String selfieUrl,
    required String poseType,
  }) async {
    final verification = VerificationEntity(
      id: _uuid.v4(),
      userId: userId,
      selfieUrl: selfieUrl,
      poseType: poseType,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('verifications').insert({
          'id': verification.id,
          'user_id': userId,
          'selfie_url': selfieUrl,
          'pose_type': poseType,
          'status': 'pending',
          'submitted_at': verification.submittedAt.toIso8601String(),
        });
      } catch (_) {}
    }

    _currentVerification = verification;
    await Future.delayed(const Duration(milliseconds: 500));
    return verification;
  }

  @override
  Future<VerificationEntity> getVerificationStatus(String userId) async {
    if (_currentVerification != null) {
      return _currentVerification!;
    }

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!
            .from('verifications')
            .select()
            .eq('user_id', userId)
            .order('submitted_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (res != null) {
          _currentVerification = VerificationEntity(
            id: res['id'] ?? _uuid.v4(),
            userId: res['user_id'] ?? userId,
            selfieUrl: res['selfie_url'] ?? '',
            poseType: res['pose_type'] ?? 'smile',
            status: res['status'] ?? 'unverified',
            submittedAt: res['submitted_at'] != null
                ? DateTime.parse(res['submitted_at'])
                : DateTime.now(),
            reviewedAt: res['reviewed_at'] != null ? DateTime.parse(res['reviewed_at']) : null,
            rejectionReason: res['rejection_reason'],
          );
          return _currentVerification!;
        }
      } catch (_) {}
    }

    return VerificationEntity(
      id: 'default-verification',
      userId: userId,
      selfieUrl: '',
      poseType: 'smile',
      status: 'unverified',
      submittedAt: DateTime.now(),
    );
  }

  @override
  Future<void> blockUser({required String userId, required String targetUserId}) async {
    _blockedUserIds.add(targetUserId);

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('blocks').insert({
          'blocker_id': userId,
          'blocked_id': targetUserId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> unblockUser({required String userId, required String targetUserId}) async {
    _blockedUserIds.remove(targetUserId);

    if (SupabaseService.isInitialized && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('blocks')
            .delete()
            .match({'blocker_id': userId, 'blocked_id': targetUserId});
      } catch (_) {}
    }
  }

  @override
  Future<List<String>> getBlockedUserIds(String userId) async {
    return _blockedUserIds.toList();
  }
}
