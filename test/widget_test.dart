import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchstick/main.dart';

void main() {
  testWidgets('MatchStickApp renders DesignSystemShowcase smoke test', (WidgetTester tester) async {
    // Build MatchStickApp inside ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MatchStickApp(),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify editorial hero title exists
    expect(find.text('meet someone\nworth knowing.'), findsOneWidget);
    expect(find.text('match stick design system'), findsOneWidget);
  });
}
