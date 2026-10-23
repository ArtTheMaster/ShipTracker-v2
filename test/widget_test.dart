import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gjandasher_shiptracker/app.dart';

void main() {
  testWidgets('ShipTrackerApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShipTrackerApp(),
      ),
    );

    expect(find.text('GJandAsher ShipTracker'), findsOneWidget);
  });
}