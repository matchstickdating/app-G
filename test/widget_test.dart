import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchstick/features/ai/presentation/screens/match_coach_screen.dart';
import 'package:matchstick/features/auth/presentation/screens/login_screen.dart';
import 'package:matchstick/features/chat/presentation/screens/matches_and_chat_screen.dart';
import 'package:matchstick/features/date_planner/presentation/screens/date_ideas_screen.dart';
import 'package:matchstick/features/date_planner/presentation/screens/date_planner_screen.dart';
import 'package:matchstick/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:matchstick/features/matching/presentation/screens/likes_screen.dart';
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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('welcome\nback.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('DiscoveryScreen renders gestural card feed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DiscoveryScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DiscoveryScreen), findsOneWidget);
    expect(find.text('intentional discovery.'), findsOneWidget);
  });

  testWidgets('LikesScreen renders incoming likes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LikesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LikesScreen), findsOneWidget);
    expect(find.text('likes received'), findsOneWidget);
  });

  testWidgets('MatchesAndChatScreen renders conversations', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MatchesAndChatScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MatchesAndChatScreen), findsOneWidget);
    expect(find.text('messages'), findsOneWidget);
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

  testWidgets('MatchCoachScreen renders coach header and quick prompts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MatchCoachScreen(partnerName: 'Maya'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MatchCoachScreen), findsOneWidget);
    expect(find.text('match coach'), findsOneWidget);
    expect(find.text('what should i ask next?'), findsOneWidget);
  });

  testWidgets('DatePlannerScreen renders planner controls and options', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DatePlannerScreen(partnerName: 'Maya'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.byType(DatePlannerScreen), findsOneWidget);
    expect(find.text('ai date planner'), findsOneWidget);
    expect(find.text('plan a date.'), findsOneWidget);
  });

  testWidgets('DateIdeasScreen renders curated concepts and category filters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DateIdeasScreen(partnerName: 'Maya'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DateIdeasScreen), findsOneWidget);
    expect(find.text('curated date ideas'), findsOneWidget);
    expect(find.text('intentional dates.'), findsOneWidget);
    expect(find.text('vintage bookstore & quiet pour-over'), findsOneWidget);
  });
}
