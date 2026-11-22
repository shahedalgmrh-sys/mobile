import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/modules/customer/screens/messages_list_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Signed-in customer used to verify that the current user is excluded from
/// `participants[]` when the row picks the other party.
const _myId = 'u-me';

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(super.ref) {
    state = const AuthState(isAuthenticated: true, userId: _myId);
  }
}

class _StubConversations extends CustomerConversationsController {
  _StubConversations(this._items);

  final List<Map<String, dynamic>> _items;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() => AsyncData(_items);
}

class _PendingConversations extends CustomerConversationsController {
  _PendingConversations(this._pending);

  final Future<List<Map<String, dynamic>>> _pending;
  bool _disposed = false;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _load();
    return const AsyncLoading();
  }

  Future<void> _load() async {
    final items = await _pending;
    if (_disposed) return;
    state = AsyncData(items);
  }
}

class _FailingConversations extends CustomerConversationsController {
  int calls = 0;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    calls++;
    return AsyncError(
      const ApiException(
        ServerFailure(code: 404, message: 'المحادثة غير موجودة.'),
      ),
      StackTrace.current,
    );
  }
}

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: [
      authNotifierProvider.overrideWith((ref) => _TestAuthNotifier(ref)),
      ...overrides,
    ],
    child: const MaterialApp(home: MessagesListScreen()),
  );
}

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(_wrap(overrides));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'renders the other participant name, photo, preview and local date',
    (tester) async {
      const lastAt = '2026-11-20T12:00:00Z';
      final conversations = <Map<String, dynamic>>[
        {
          'id': 'conv-1',
          'subject': 'عنوان لا يجب أن يظهر',
          'last_message_at': lastAt,
          'participants': [
            {'id': _myId, 'name': 'أنا', 'role': 'customer', 'avatar': null},
            {
              'id': 'u-provider',
              'name': 'شركة النور',
              'role': 'provider',
              'avatar': 'https://example.com/provider.png',
            },
          ],
          'latest_message': {
            'id': 'm-1',
            'conversation_id': 'conv-1',
            'body': 'تم تأكيد الموعد',
            'sender': {
              'id': 'u-provider',
              'name': 'شركة النور',
              'avatar': null,
            },
            'created_at': lastAt,
          },
          'created_at': '2026-11-19T08:00:00Z',
        },
      ];

      await _pump(tester, [
        customerConversationsProvider.overrideWith(
          () => _StubConversations(conversations),
        ),
      ]);

      expect(find.text('شركة النور'), findsOneWidget);
      expect(find.text('أنا'), findsNothing);
      expect(find.text('عنوان لا يجب أن يظهر'), findsNothing);
      expect(find.text('تم تأكيد الموعد'), findsOneWidget);
      expect(find.text(formatDate(lastAt)), findsOneWidget);
      expect(find.text(lastAt), findsNothing);

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.foregroundImage, isA<NetworkImage>());
      expect(
        (avatar.foregroundImage! as NetworkImage).url,
        'https://example.com/provider.png',
      );
    },
  );

  testWidgets('falls back to subject when the participant has no name', (
    tester,
  ) async {
    final conversations = <Map<String, dynamic>>[
      {
        'id': 'conv-2',
        'subject': 'استفسار عن التنظيف',
        'last_message_at': '2026-11-20T09:00:00Z',
        'participants': [
          {'id': _myId, 'name': 'أنا', 'role': 'customer'},
          {'id': 'u-provider', 'role': 'provider'},
        ],
        'latest_message': {
          'id': 'm-2',
          'body': 'مرحباً بك',
          'created_at': '2026-11-20T09:00:00Z',
        },
      },
    ];

    await _pump(tester, [
      customerConversationsProvider.overrideWith(
        () => _StubConversations(conversations),
      ),
    ]);

    expect(find.text('استفسار عن التنظيف'), findsOneWidget);
    expect(find.text('مرحباً بك'), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.foregroundImage, isNull);
    expect(find.text('ا'), findsOneWidget);
  });

  testWidgets('uses a clear generic label when name and subject are absent', (
    tester,
  ) async {
    final conversations = <Map<String, dynamic>>[
      {
        'id': 'conv-3',
        'last_message_at': '2026-11-20T09:00:00Z',
        'participants': [
          {'id': _myId, 'name': 'أنا', 'role': 'customer'},
          {'id': 'u-provider', 'role': 'provider'},
        ],
        'latest_message': {'body': 'رسالة جديدة'},
      },
    ];

    await _pump(tester, [
      customerConversationsProvider.overrideWith(
        () => _StubConversations(conversations),
      ),
    ]);

    expect(find.text('محادثة'), findsOneWidget);
    expect(find.text('رسالة جديدة'), findsOneWidget);
  });

  testWidgets('shows the real API failure message and retries the request', (
    tester,
  ) async {
    final controller = _FailingConversations();
    await _pump(tester, [
      customerConversationsProvider.overrideWith(() => controller),
    ]);

    expect(find.text('المحادثة غير موجودة.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(controller.calls, 2);
  });

  testWidgets('keeps the existing empty state', (tester) async {
    await _pump(tester, [
      customerConversationsProvider.overrideWith(
        () => _StubConversations(const <Map<String, dynamic>>[]),
      ),
    ]);

    expect(find.text('لا توجد رسائل بعد'), findsOneWidget);
    expect(find.text('تبدأ المحادثة مع مزود الخدمة بعد الحجز'), findsOneWidget);
  });

  testWidgets('keeps the shimmer loading state while the request is pending', (
    tester,
  ) async {
    final pending = Completer<List<Map<String, dynamic>>>();
    await tester.pumpWidget(
      _wrap([
        customerConversationsProvider.overrideWith(
          () => _PendingConversations(pending.future),
        ),
      ]),
    );
    await tester.pump();

    expect(find.byType(ShimmerCard), findsNWidgets(3));

    pending.complete(const <Map<String, dynamic>>[]);
    await tester.pumpAndSettle();
    expect(find.text('لا توجد رسائل بعد'), findsOneWidget);
  });
}
