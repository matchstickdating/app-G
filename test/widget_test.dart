import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchstick/core/widgets/design_system_showcase.dart';
import 'package:matchstick/features/auth/presentation/screens/login_screen.dart';
import 'package:matchstick/features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import 'package:matchstick/features/profile/presentation/screens/profile_detail_screen.dart';
import 'package:matchstick/main.dart';

void main() {
  testWidgets('MatchStickApp renders AuthGate with LoginScreen by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MatchStickApp(),
      ),
    );

    // Initial pump frame
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Login Screen elements
    expect(find.text('welcome\nback.'), findsOneWidget);
    expect(find.text('sign in to continue meaningful conversations.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('DesignSystemShowcase renders design tokens cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DesignSystemShowcase(
          isDark: false,
          onToggleTheme: () {},
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('meet someone\nworth knowing.'), findsOneWidget);
    expect(find.text('match stick design system'), findsOneWidget);
  });

  testWidgets('OnboardingFlowScreen renders step 1 questions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingFlowScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('what should\nwe call you?'), findsOneWidget);
    expect(find.text('first name'), findsOneWidget);
  });

  testWidgets('ProfileDetailScreen renders editorial portfolio view', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileDetailScreen(isMyProfile: true),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ProfileDetailScreen), findsOneWidget);
  });
}
