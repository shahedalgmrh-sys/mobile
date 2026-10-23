import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/auth_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/models/app_config.dart';
import 'package:saber_flutter/modules/auth/screens/forgot_password_screen.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

/// Repository double: the forgot/reset calls succeed without any network.
class _FakeAuthRepository extends AuthRepository {
  const _FakeAuthRepository(super.source);

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {}
}

Future<void> _pumpScreen(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.customer()),
      authRepositoryProvider.overrideWith(
        (ref) => _FakeAuthRepository(
          AuthRemoteSource(ref.watch(apiClientProvider)),
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ForgotPasswordScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('Step 1 → 2: valid email moves to the token step', (
    tester,
  ) async {
    await _pumpScreen(tester);

    expect(find.byKey(const Key('fp_email')), findsOneWidget);
    expect(find.byKey(const Key('fp_token')), findsNothing);

    await tester.enterText(find.byKey(const Key('fp_email')), 'a@b.com');
    await tester.pump();

    await tester.tap(find.text('إرسال رابط الاستعادة'));
    await tester.pump();

    expect(find.byKey(const Key('fp_token')), findsOneWidget);
    expect(find.byKey(const Key('fp_password')), findsOneWidget);
    expect(find.byKey(const Key('fp_confirm')), findsOneWidget);
  });

  testWidgets('Step 2 reset stays disabled until token + passwords match', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.enterText(find.byKey(const Key('fp_email')), 'a@b.com');
    await tester.pump();
    await tester.tap(find.text('إرسال رابط الاستعادة'));
    await tester.pump();

    SahelButton resetButton() =>
        tester.widget<SahelButton>(find.byType(SahelButton).first);

    // Token missing → disabled.
    expect(resetButton().onPressed, isNull);

    await tester.enterText(find.byKey(const Key('fp_token')), 'tok123');
    await tester.enterText(find.byKey(const Key('fp_password')), 'longenough1');
    await tester.enterText(find.byKey(const Key('fp_confirm')), 'different11');
    await tester.pump();

    // Mismatched confirmation → still disabled + inline error.
    expect(resetButton().onPressed, isNull);
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('fp_confirm')), 'longenough1');
    await tester.pump();

    expect(resetButton().onPressed, isNotNull);
  });

  testWidgets('Deep-link prefill lands directly on the reset step', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.customer()),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            AuthRemoteSource(ref.watch(apiClientProvider)),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ForgotPasswordScreen(
            initialEmail: 'linked@user.com',
            initialToken: 'tok456',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('fp_email')), findsNothing);
    expect(find.byKey(const Key('fp_token')), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byKey(const Key('fp_token'))).controller!.text,
      'tok456',
    );
  });
}
