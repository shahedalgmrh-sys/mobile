import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saber_flutter/app/sahel_app.dart';
import 'package:saber_flutter/models/app_config.dart';

void main() {
  testWidgets('Smoke test: app renders', (WidgetTester tester) async {
    await tester.pumpWidget(SahelApp(config: AppConfig.customer()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
