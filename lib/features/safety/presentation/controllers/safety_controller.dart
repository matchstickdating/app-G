import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/safety_repository_impl.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/verification_entity.dart';
import '../../domain/repositories/safety_repository.dart';

class SafetyState {
  final bool isSubmitting;
  final VerificationEntity? verification;
  final List<String> blockedUserIds;
  final String? errorMessage;
  final String? successMessage;

  const SafetyState({
    this.isSubmitting = false,
    this.verification,
    this.blockedUserIds = const [],
    this.errorMessage,
    this.successMessage,
  });

  SafetyState copyWith({
    bool? isSubmitting,
    VerificationEntity? verification,
    List<String>? blockedUserIds,
    String? errorMessage,
    String? successMessage,
  }) {
    return SafetyState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      verification: verification ?? this.verification,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  return SafetyRepositoryImpl();
});

class SafetyController extends Notifier<SafetyState> {
  final _uuid = const Uuid();

  SafetyRepository get _repo => ref.read(safetyRepositoryProvider);

  @override
  SafetyState build() {
    return const SafetyState();
  }

  Future<void> loadVerificationStatus(String userId) async {
    try {
      final v = await _repo.getVerificationStatus(userId);
      state = state.copyWith(verification: v);
    } catch (_) {}
  }

  Future<bool> submitVerification({
    required String userId,
    required String selfieUrl,
    required String poseType,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      final v = await _repo.submitSelfieVerification(
        userId: userId,
        selfieUrl: selfieUrl,
        poseType: poseType,
      );
      state = state.copyWith(
        isSubmitting: false,
        verification: v,
        successMessage: 'selfie submitted for review.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'failed to submit verification.',
      );
      return false;
    }
  }

  Future<bool> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
    required String details,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      final report = ReportEntity(
        id: _uuid.v4(),
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reportedUserName: reportedUserName,
        reason: reason,
        details: details,
        createdAt: DateTime.now(),
      );

      await _repo.submitReport(report);
      // Auto-block reported user for safety
      await blockUser(userId: reporterId, targetUserId: reportedUserId);

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'report submitted and user blocked.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'failed to submit report.',
      );
      return false;
    }
  }

  Future<void> blockUser({required String userId, required String targetUserId}) async {
    try {
      await _repo.blockUser(userId: userId, targetUserId: targetUserId);
      final currentBlocked = List<String>.from(state.blockedUserIds);
      if (!currentBlocked.contains(targetUserId)) {
        currentBlocked.add(targetUserId);
      }
      state = state.copyWith(blockedUserIds: currentBlocked);
    } catch (_) {}
  }

  Future<void> unblockUser({required String userId, required String targetUserId}) async {
    try {
      await _repo.unblockUser(userId: userId, targetUserId: targetUserId);
      final currentBlocked = List<String>.from(state.blockedUserIds)
        ..remove(targetUserId);
      state = state.copyWith(blockedUserIds: currentBlocked);
    } catch (_) {}
  }
}

final safetyControllerProvider =
    NotifierProvider<SafetyController, SafetyState>(SafetyController.new);
