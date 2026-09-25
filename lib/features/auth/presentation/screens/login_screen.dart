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
import '../../../onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../../../core/routing/main_navigation_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -8),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
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
    } else if (success && mounted) {
      final authState = ref.read(authControllerProvider);
      final targetPage = authState.status == AuthStatus.onboardingRequired
          ? const OnboardingFlowScreen()
          : const MainNavigationShell();
      Navigator.of(context).pushAndRemoveUntil(
        MotionTokens.editorialPageRoute(
          page: targetPage,
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // App Brand Mark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'MEMBER ACCESS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3D Animated Hero Graphic
              Center(
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _floatAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: isDark ? 0.35 : 0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Image.asset(
                        'assets/images/login_love_3d.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.favorite,
                          size: 64,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Editorial Headline
              const MatchText(
                'welcome\nback.',
                style: MatchTextStyle.hero,
              ),
              const SizedBox(height: 8),
              const MatchText(
                'sign in to continue meaningful conversations.',
                style: MatchTextStyle.bodyMedium,
              ),
              const SizedBox(height: 32),

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
              const SizedBox(height: 32),

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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
