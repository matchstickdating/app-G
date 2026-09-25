import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../widgets/match_loading_indicator.dart';
import 'main_navigation_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(
            child: MatchLoadingIndicator(type: MatchLoadingType.pulse),
          ),
        );
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.onboardingRequired:
        return const OnboardingFlowScreen();
      case AuthStatus.authenticated:
        return const MainNavigationShell();
    }
  }
}
