import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/match_button.dart';
import '../../../../core/widgets/match_text.dart';
import '../../../../core/widgets/match_text_field.dart';
import '../../../../core/widgets/match_toast.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      MatchToast.show(context, message: 'enter a valid email address.', type: ToastType.error);
      return;
    }
    if (password.isEmpty || password.length < 6) {
      MatchToast.show(context, message: 'password must be at least 6 characters.', type: ToastType.error);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signIn(email, password);
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage ?? 'failed to sign in.';
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
                'welcome\nback.',
                style: MatchTextStyle.hero,
              ),
              const SizedBox(height: 12),
              const MatchText(
                'sign in to continue meaningful conversations.',
                style: MatchTextStyle.bodyMedium,
              ),
              const SizedBox(height: 40),

              // Input Fields
              MatchTextField(
                controller: _emailController,
                label: 'email',
                hintText: 'alex@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              MatchTextField(
                controller: _passwordController,
                label: 'password',
                hintText: '••••••••',
                isPassword: true,
                onSubmitted: _handleLogin,
              ),
              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MotionTokens.editorialPageRoute(
                        page: const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      letterSpacing: -0.01 * 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Primary Login Action
              MatchButton(
                text: 'sign in',
                variant: MatchButtonVariant.primary,
                isLoading: authState.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              // Sign Up Navigation
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MatchText(
                      'new to match stick? ',
                      style: MatchTextStyle.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MotionTokens.editorialPageRoute(
                            page: const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'create an account',
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
