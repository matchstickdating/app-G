import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      MatchToast.show(context, message: 'enter a valid email address.', type: ToastType.error);
      return;
    }
    if (password.length < 6) {
      MatchToast.show(context, message: 'password must be at least 6 characters.', type: ToastType.error);
      return;
    }
    if (password != confirmPassword) {
      MatchToast.show(context, message: 'passwords do not match.', type: ToastType.error);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signUp(email, password);
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'failed to create account.';
      MatchToast.show(context, message: error, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // App Brand Mark
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const MatchText(
                    'match stick',
                    style: MatchTextStyle.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Editorial Headline
              const MatchText(
                'let\'s\nbegin.',
                style: MatchTextStyle.hero,
              ),
              const SizedBox(height: 12),
              const MatchText(
                'dating, with a little more intention.',
                style: MatchTextStyle.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Inputs
              MatchTextField(
                controller: _emailController,
                label: 'email',
                hintText: 'alex@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              MatchTextField(
                controller: _passwordController,
                label: 'create password',
                hintText: '••••••••',
                isPassword: true,
              ),
              const SizedBox(height: 20),
              MatchTextField(
                controller: _confirmPasswordController,
                label: 'confirm password',
                hintText: '••••••••',
                isPassword: true,
                onSubmitted: _handleSignUp,
              ),
              const SizedBox(height: 36),

              // Submit Button
              MatchButton(
                text: 'create account',
                variant: MatchButtonVariant.primary,
                isLoading: authState.isLoading,
                onPressed: _handleSignUp,
              ),
              const SizedBox(height: 24),

              // Login Navigation
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MatchText(
                      'already have an account? ',
                      style: MatchTextStyle.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MotionTokens.editorialPageRoute(
                            page: const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'sign in',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
