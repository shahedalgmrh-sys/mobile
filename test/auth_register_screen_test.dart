import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/modules/auth/screens/register_screen.dart';

void main() {
  testWidgets(
      'provider role reveals the documents section; customer role hides it',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RegisterScreen()),
      ),
    );

    expect(find.text('ملف مزود الخدمة'), findsNothing);
    expect(find.text('اختيار الوثائق'), findsNothing);

    await tester.tap(find.text('مزود خدمة'));
    await tester.pumpAndSettle();

    expect(find.text('ملف مزود الخدمة'), findsOneWidget);
    expect(find.text('اختيار الوثائق'), findsOneWidget);
    expect(
      find.textContaining('سيُستخدم اسمك الكامل اسماً تجارياً مبدئياً'),
      findsOneWidget,
    );

    // Switching back to customer restores the original minimal form.
    await tester.tap(find.text('أنا عميل'));
    await tester.pumpAndSettle();

    expect(find.text('ملف مزود الخدمة'), findsNothing);
    expect(find.text('اختيار الوثائق'), findsNothing);
  });
}
