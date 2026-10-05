import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchstick/core/widgets/profile_photo.dart';

void main() {
  testWidgets('embedded onboarding photo uses memory image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfilePhoto(
            name: 'Ananya',
            url: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1sAAAAASUVORK5CYII=',
          ),
        ),
      ),
    );
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
  });

  for (final source in [null, '', 'not-a-photo', 'data:image/png;base64,%%%']) {
    testWidgets('unavailable photo has an honest fallback: $source', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfilePhoto(name: 'Ananya', url: source),
          ),
        ),
      );
      expect(find.text('Photo unavailable'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
