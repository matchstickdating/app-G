import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matchstick/core/theme/app_theme.dart';
import 'package:matchstick/core/routing/main_navigation_shell.dart';
import 'package:matchstick/features/discovery/domain/entities/discovery_card_entity.dart';
import 'package:matchstick/features/discovery/presentation/controllers/discovery_controller.dart';
import 'package:matchstick/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:matchstick/features/discovery/presentation/widgets/discovery_card.dart';
import 'package:matchstick/features/discovery/presentation/widgets/discovery_header.dart';
import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';
import 'package:matchstick/features/profile/presentation/controllers/profile_controller.dart';

final _profile = ProfileEntity(
  id: 'preview',
  displayName: 'Alexandra',
  birthdate: DateTime(1998),
  gender: 'woman',
  genderPreference: const [],
  relationshipGoal: 'long_term',
  createdAt: DateTime(2025),
  locationCity: 'San Francisco',
  interests: const ['Photography', 'Coffee', 'Music'],
);

class _Discovery extends DiscoveryController {
  @override
  DiscoveryState build() => DiscoveryState(
    cards: [DiscoveryCardEntity(profile: _profile, compatibilityScore: 92)],
    todaysPicks: [
      DiscoveryCardEntity(profile: _profile, compatibilityScore: 92),
    ],
  );
}

class _Profile extends ProfileController {
  @override
  ProfileState build() => ProfileState(profile: _profile);
}

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('dashboard controls remain reachable at $size, text $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              discoveryControllerProvider.overrideWith(_Discovery.new),
              profileControllerProvider.overrideWith(_Profile.new),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  padding: const EdgeInsets.only(top: 44),
                ),
                child: child!,
              ),
              home: const Scaffold(
                body: DiscoveryScreen(),
                bottomNavigationBar: SizedBox(height: 64),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final card = tester.getRect(find.byType(DiscoveryCard));
        expect(card.left, 0);
        expect(card.width, size.width);
        expect(
          tester.getBottomLeft(find.byType(DiscoveryHeader)).dy,
          lessThan(tester.getTopLeft(find.text('Alexandra')).dy),
        );
        final name = tester.getRect(find.text('Alexandra'));
        final age = tester.getRect(find.text('${_profile.age}'));
        expect(age.left - name.right, greaterThanOrEqualTo(12));
        await tester.ensureVisible(find.byTooltip('Like'));
        expect(find.byTooltip('Like').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Discovery options'));
        await tester.tap(find.byTooltip('Discovery options'));
        await tester.pumpAndSettle();
        expect(find.text('Rewind last profile'), findsOneWidget);
        expect(find.text('Date ideas'), findsOneWidget);
        expect(find.text('Coach'), findsOneWidget);
        expect(find.text('Safety'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('photo actions invoke the correct callbacks on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final calls = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DiscoveryCard(
            card: DiscoveryCardEntity(
              profile: ProfileEntity(
                id: 'test',
                displayName: 'A very long profile name',
                birthdate: DateTime(1998),
                gender: 'woman',
                genderPreference: const [],
                relationshipGoal: 'long_term',
                createdAt: DateTime(2025),
                interests: const ['Photography', 'Coffee', 'Music'],
              ),
              compatibilityScore: 92,
            ),
            onSwipeRight: () => calls.add('like'),
            onSwipeLeft: () => calls.add('pass'),
            onSwipeUp: () => calls.add('super'),
            onTap: () => calls.add('profile'),
          ),
        ),
      ),
    );
    for (final label in ['Like', 'Pass', 'Super like', 'View profile']) {
      await tester.tap(
        find.widgetWithIcon(IconButton, switch (label) {
          'Like' => Icons.favorite_rounded,
          'Pass' => Icons.close_rounded,
          'Super like' => Icons.bolt_rounded,
          _ => Icons.person_outline_rounded,
        }),
      );
      await tester.pump();
    }
    expect(calls, ['like', 'pass', 'super', 'profile']);
    final likePosition = tester.getCenter(
      find.widgetWithIcon(IconButton, Icons.favorite_rounded),
    );
    final passPosition = tester.getCenter(
      find.widgetWithIcon(IconButton, Icons.close_rounded),
    );
    expect(likePosition.dx, closeTo(passPosition.dx, 1));
    expect(likePosition.dy, greaterThan(passPosition.dy));
    expect(likePosition.dx, greaterThan(260));
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile detail opened from discovery has one back control', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryControllerProvider.overrideWith(_Discovery.new),
          profileControllerProvider.overrideWith(_Profile.new),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const DiscoveryScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('View profile'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('back'), findsOneWidget);
    expect(find.byTooltip('close profile'), findsNothing);
    expect(find.text('pass'), findsOneWidget);
    expect(find.text('super like'), findsOneWidget);
    expect(find.text('like'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('main navigation uses a shared white pill across tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryControllerProvider.overrideWith(_Discovery.new),
          profileControllerProvider.overrideWith(_Profile.new),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MainNavigationShell(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('primary-navigation-pill')), findsOneWidget);
    for (final label in [
      'Discover',
      'Likes',
      'Community',
      'Messages',
      'Profile',
    ]) {
      expect(find.byTooltip(label), findsOneWidget);
    }
    for (final label in [
      'Likes',
      'Community',
      'Messages',
      'Profile',
      'Discover',
    ]) {
      await tester.tap(find.byTooltip(label));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('primary-navigation-pill')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
