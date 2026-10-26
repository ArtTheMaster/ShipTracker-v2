import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gjandasher_shiptracker/app.dart';

void main() {
  testWidgets('ShipTrackerApp loads smoke test', (WidgetTester tester) async {
    // 1. Create a dummy navigator key for the test environment
    final testNavigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      // 2. Remove the 'const' keyword here
      ProviderScope(
        // 3. Pass the test key to the app
        child: ShipTrackerApp(navigatorKey: testNavigatorKey),
      ),
    );

    expect(find.text('GJandAsher ShipTracker'), findsOneWidget);
  });
}