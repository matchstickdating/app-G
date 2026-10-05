import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchstick/features/discovery/presentation/widgets/people_search.dart';
import 'package:matchstick/features/profile/domain/entities/profile_entity.dart';

void main() {
  testWidgets(
    'search filters names, cities and interests and returns selection',
    (tester) async {
      final alex = ProfileEntity(
        id: 'alex',
        displayName: 'Alex',
        birthdate: DateTime(1998),
        gender: 'woman',
        genderPreference: const [],
        relationshipGoal: 'long_term',
        locationCity: 'Chennai',
        interests: const ['Photography'],
        createdAt: DateTime(2025),
      );
      ProfileEntity? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await showSearch<ProfileEntity?>(
                    context: context,
                    delegate: PeopleSearch([alex]),
                  );
                },
                child: const Text('Search'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      for (final query in ['aLeX', 'chennai', 'photo']) {
        await tester.enterText(find.byType(TextField), query);
        await tester.pumpAndSettle();
        expect(find.text('Alex'), findsOneWidget);
      }
      await tester.enterText(find.byType(TextField), 'no match');
      await tester.pumpAndSettle();
      expect(
        find.text('No matching profiles in your current feed.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();
      expect(selected, same(alex));
    },
  );
}
