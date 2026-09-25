import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      MatchToast.show(context, message: 'enter a valid email address.', type: ToastType.error);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).sendPasswordReset(email);
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const MatchText(
                'reset\npassword.',
                style: MatchTextStyle.hero,
              ),
              const SizedBox(height: 12),
              MatchText(
                _emailSent
                    ? 'check your inbox for password reset instructions.'
                    : 'enter your email address and we\'ll send you a recovery link.',
                style: MatchTextStyle.bodyMedium,
              ),
              const SizedBox(height: 36),

              if (!_emailSent) ...[
                MatchTextField(
                  controller: _emailController,
                  label: 'email',
                  hintText: 'alex@example.com',
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: _handleReset,
                ),
                const SizedBox(height: 32),
                MatchButton(
                  text: 'send recovery link',
                  variant: MatchButtonVariant.primary,
                  isLoading: authState.isLoading,
                  onPressed: _handleReset,
                ),
              ] else ...[
                MatchButton(
                  text: 'back to sign in',
                  variant: MatchButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
