import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saber_flutter/app/sahel_app.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/models/app_config.dart';

/// Boots the app and flushes the splash-screen timer (~1.8s) so the router
/// settles on a public route (login) without pending timers.
Future<void> _bootApp(WidgetTester tester, {required AppConfig config}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: SahelApp(config: config),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

void main() {
  testWidgets('Smoke test: app renders', (WidgetTester tester) async {
    final config = AppConfig.customer();
    await _bootApp(tester, config: config);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // Guards the visual identity against layout overflow across the screen sizes
  // the app must support: small/large phones and tablets.
  group('Responsive layout — no overflow', () {
    const sizes = <String, Size>{
      'small phone 320x568': Size(320, 568),
      'medium phone 390x844': Size(390, 844),
      'large phone 430x932': Size(430, 932),
      'tablet 834x1112': Size(834, 1112),
    };

    sizes.forEach((label, size) {
      testWidgets('renders cleanly at $label', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _bootApp(tester, config: AppConfig.customer());

        expect(tester.takeException(), isNull);
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}
