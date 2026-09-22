import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saber_flutter/app/sahel_app.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/models/app_config.dart';

void main() {
  testWidgets('Smoke test: app renders', (WidgetTester tester) async {
    final config = AppConfig.customer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(config)],
        child: SahelApp(config: config),
      ),
    );
    await tester.pump();
    // Flush the splash-screen timer (~1.8s) so no pending timers remain.
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
