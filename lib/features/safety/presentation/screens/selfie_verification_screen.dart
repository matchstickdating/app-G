import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_card.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/safety_controller.dart';

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  ConsumerState<SelfieVerificationScreen> createState() => _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends ConsumerState<SelfieVerificationScreen> {
  int _currentStep = 0; // 0: instructions, 1: camera, 2: review
  final String _selectedPose = 'smile & turn slightly left';
  bool _isCapturing = false;
  String? _capturedSelfieUrl;

  Future<void> _simulateCapture() async {
    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _isCapturing = false;
      _capturedSelfieUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800';
      _currentStep = 2; // Move to review
    });
  }

  Future<void> _handleSubmit() async {
    final userId = ref.read(authControllerProvider).userId ?? 'current-user';

    final success = await ref.read(safetyControllerProvider.notifier).submitVerification(
          userId: userId,
          selfieUrl: _capturedSelfieUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
          poseType: _selectedPose,
        );

    if (mounted) {
      if (success) {
        MatchToast.show(
          context,
          message: 'verification submitted. badges are awarded within 2 hours.',
          type: ToastType.success,
        );
        Navigator.of(context).pop();
      } else {
        MatchToast.show(
          context,
          message: 'failed to submit. please try again.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safetyState = ref.watch(safetyControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const MatchText(
          'photo verification',
          style: MatchTextStyle.navigation,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Dots
              Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Step Content
              Expanded(
                child: _buildCurrentStep(isDark),
              ),

              // Bottom Action
              _buildBottomButton(safetyState),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildInstructionStep(isDark);
      case 1:
        return _buildCameraStep(isDark);
      case 2:
        return _buildReviewStep(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInstructionStep(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MatchText('get verified.', style: MatchTextStyle.hero),
          const SizedBox(height: 8),
          Text(
            'verified profiles get up to 3x more meaningful conversations and an official verification badge.',
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildInstructionCard(
            icon: Icons.face_retouching_natural,
            title: 'pose prompt',
            desc: 'you will be asked to copy a simple gesture to confirm you are real.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInstructionCard(
            icon: Icons.light_mode_outlined,
            title: 'good lighting',
            desc: 'ensure your face is well-lit and unobstructed by sunglasses or heavy filters.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInstructionCard(
            icon: Icons.lock_outline,
            title: 'private & secure',
            desc: 'this selfie is strictly used for biometric review and will never appear on your profile.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraStep(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'pose: "$_selectedPose"',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Viewfinder
        Expanded(
          child: Center(
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(130),
                border: Border.all(color: AppColors.accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 160,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'center face inside oval',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MatchText('review selfie.', style: MatchTextStyle.hero),
        const SizedBox(height: 8),
        Text(
          'make sure your face is clearly visible and matches the prompt pose.',
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 24),

        Center(
          child: Container(
            width: 200,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800'),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        MatchCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 20, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'pose matched: "$_selectedPose"',
                  style: AppTypography.bodyMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return MatchCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toLowerCase(),
                  style: AppTypography.headingSmall().copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(SafetyState safetyState) {
    if (_currentStep == 0) {
      return MatchButton(
        text: 'i am ready',
        variant: MatchButtonVariant.primary,
        onPressed: () => setState(() => _currentStep = 1),
      );
    } else if (_currentStep == 1) {
      return MatchButton(
        text: 'capture selfie',
        variant: MatchButtonVariant.accent,
        isLoading: _isCapturing,
        onPressed: _simulateCapture,
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: MatchButton(
              text: 'retake',
              variant: MatchButtonVariant.outline,
              onPressed: () => setState(() => _currentStep = 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MatchButton(
              text: 'submit for review',
              variant: MatchButtonVariant.primary,
              isLoading: safetyState.isSubmitting,
              onPressed: _handleSubmit,
            ),
          ),
        ],
      );
    }
  }
}
