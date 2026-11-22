import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/modules/customer/screens/chat_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

/// Signed-in customer used to distinguish own messages from incoming ones.
const _myId = 'u-me';
const _threadId = 'c1';

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(super.ref) {
    state = const AuthState(
      isAuthenticated: true,
      userId: _myId,
      role: UserRole.customer,
      sessionGeneration: 1,
    );
  }

  /// Moves the test to another account session (or signs it out when
  /// [signedIn] is false). `sessionScopeProvider` derives from this state.
  void switchTo(
    String userId,
    int generation, {
    bool signedIn = true,
  }) {
    state = AuthState(
      isAuthenticated: signedIn,
      userId: signedIn ? userId : null,
      role: signedIn ? UserRole.customer : null,
      sessionGeneration: generation,
    );
  }
}

/// Mirrors the JSON shaped by `ConversationResource` + `MessageResource`
/// (`{conversation: {...}, messages: [...]}` flattened by the repository).
Map<String, dynamic> _message({
  required String id,
  required String senderId,
  required String senderName,
  String? senderAvatar,
  required String body,
  String createdAt = '2026-11-20T10:00:00.000000Z',
}) => {
  'id': id,
  'conversation_id': _threadId,
  'sender': {'id': senderId, 'name': senderName, 'avatar': senderAvatar},
  'body': body,
  'is_read': false,
  'read_at': null,
  'attachments': <dynamic>[],
  'created_at': createdAt,
};

Map<String, dynamic> _thread(
  List<Map<String, dynamic>> messages, {
  String providerName = 'مزود الخدمة',
  String? providerAvatar,
}) => {
  'id': _threadId,
  'subject': 'استفسار عن الخدمة',
  'last_message_at': messages.isEmpty ? null : messages.last['created_at'],
  'participants': [
    {'id': _myId, 'name': 'أنا', 'role': 'customer', 'avatar': null},
    {
      'id': 'u-prov',
      'name': providerName,
      'role': 'provider',
      'avatar': providerAvatar,
    },
  ],
  'latest_message': messages.isEmpty ? null : messages.last,
  'created_at': '2026-11-19T09:00:00.000000Z',
  'messages': messages,
};

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository()
    : super(
        CustomerRemoteSource(
          ApiClient(
            dio: Dio(),
            baseUrl: 'http://localhost/api',
            appVersion: '1.0.0+0',
            storage: SecureStorage(),
          ),
        ),
      );

  final List<Map<String, dynamic>> messages = [];
  final List<String> sentBodies = [];
  int conversationCalls = 0;

  Object? conversationError;
  int failConversationCalls = 0;
  Object? sendError;
  Completer<void>? sendGate;

  // ---- per-account thread used by the session-isolation tests ------------
  String account = _myId;
  final Map<String, List<Map<String, dynamic>>> accountMessages = {};
  final Map<String, Object> accountErrors = {};
  final Map<String, List<Completer<void>>> conversationGates = {};
  final List<String> conversationRequests = [];
  final List<String> sendRequests = [];

  void addMessage(String accountId, Map<String, dynamic> message) =>
      accountMessages.putIfAbsent(accountId, () => []).add(message);

  Completer<void> gateConversation(String accountId) {
    final completer = Completer<void>();
    conversationGates
        .putIfAbsent('$accountId|conversation|$_threadId', () => [])
        .add(completer);
    return completer;
  }

  @override
  Future<Map<String, dynamic>> conversation(String id) async {
    final requestKey = '$account|conversation|$id';
    conversationRequests.add(requestKey);
    final queue = conversationGates[requestKey];
    if (queue != null && queue.isNotEmpty) {
      await queue.removeAt(0).future;
    }
    final accountError = accountErrors[requestKey];
    if (accountError != null) throw accountError;
    conversationCalls++;
    if (conversationError != null &&
        conversationCalls <= failConversationCalls) {
      throw conversationError!;
    }
    return _thread(accountMessages[account] ?? messages);
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String id, String body) async {
    sentBodies.add(body);
    sendRequests.add('$account|sendMessage|$id');
    // The server receives the message on the account that was active when
    // the call started, even if the session changes while it is in flight.
    final target = accountMessages[account] ?? messages;
    if (sendGate != null) await sendGate!.future;
    if (sendError != null) throw sendError!;
    final sent = _message(
      id: 'm-sent-${target.length}',
      senderId: _myId,
      senderName: 'أنا',
      body: body,
      createdAt: '2026-11-20T12:00:00.000000Z',
    );
    target.add(sent);
    return sent;
  }
}

Widget _wrap(_FakeCustomerRepository repository) => ProviderScope(
  overrides: [
    authNotifierProvider.overrideWith((ref) => _TestAuthNotifier(ref)),
    customerRepositoryProvider.overrideWithValue(repository),
  ],
  child: const MaterialApp(home: ChatScreen(threadId: _threadId)),
);

/// Pumps the screen and lets the multi-frame initial scroll settle on the
/// newest message (each post-frame pass needs its own frame in tests).
Future<void> _pumpChat(
  WidgetTester tester,
  _FakeCustomerRepository repository,
) async {
  await tester.pumpWidget(_wrap(repository));
  await tester.pumpAndSettle();
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

class _ChatHarness {
  _ChatHarness(this.container, this.auth);

  final ProviderContainer container;
  final _TestAuthNotifier auth;
}

/// Container-based harness so a test can switch the active account while the
/// screen is mounted (the plain `_wrap` above is fixed to one account).
_ChatHarness _harness(
  _FakeCustomerRepository repository, {
  String account = _myId,
}) {
  repository.account = account;
  late _TestAuthNotifier auth;
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith((ref) => auth = _TestAuthNotifier(ref)),
      customerRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  auth = container.read(authNotifierProvider.notifier) as _TestAuthNotifier;
  auth.switchTo(account, 1);
  return _ChatHarness(container, auth);
}

Future<void> _pumpHarness(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ChatScreen(threadId: _threadId)),
    ),
  );
  await tester.pumpAndSettle();
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
}

bool _hasNetworkAvatar(WidgetTester tester, String url) =>
    tester.widgetList<CircleAvatar>(find.byType(CircleAvatar)).any((avatar) {
      final image = avatar.foregroundImage;
      return image is NetworkImage && image.url == url;
    });

List<Map<String, dynamic>> _manyMessages(int count) => [
  for (var i = 1; i <= count; i++)
    _message(
      id: 'm$i',
      senderId: 'u-prov',
      senderName: 'سالم المزود',
      body: 'رسالة $i',
      createdAt: '2026-11-20T10:${i.toString().padLeft(2, '0')}:00.000000Z',
    ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('incoming message shows sender name and avatar from sender', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        senderAvatar: 'https://example.test/sender.png',
        body: 'مرحباً بك',
      ),
    );

    await _pumpChat(tester, repository);

    expect(find.text('سالم المزود'), findsOneWidget);
    expect(find.text('مرحباً بك'), findsOneWidget);
    expect(
      _hasNetworkAvatar(tester, 'https://example.test/sender.png'),
      isTrue,
    );
  });

  testWidgets('sender.id decides outgoing vs incoming bubbles', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.messages.addAll([
      _message(
        id: 'm1',
        senderId: _myId,
        senderName: 'أنا',
        body: 'أهلاً، عندي استفسار',
      ),
      _message(
        id: 'm2',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'تفضل، كيف أساعدك؟',
      ),
    ]);

    await _pumpChat(tester, repository);

    expect(find.text('أهلاً، عندي استفسار'), findsOneWidget);
    expect(find.text('تفضل، كيف أساعدك؟'), findsOneWidget);
    // Only incoming messages render the sender label.
    expect(find.text('سالم المزود'), findsOneWidget);
    expect(find.text('أنا'), findsNothing);
  });

  testWidgets('missing sender name/avatar falls back without fake names', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: '',
        body: 'رسالة بلا هوية',
      ),
    );

    await _pumpChat(tester, repository);

    expect(find.text('رسالة بلا هوية'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('محادثة'), findsNothing);
  });

  testWidgets('created_at is rendered in the local timezone', (tester) async {
    const iso = '2026-11-20T21:05:00.000000Z';
    final local = DateTime.parse(iso).toLocal();
    final expected =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'رسالة التوقيت',
        createdAt: iso,
      ),
    );

    await _pumpChat(tester, repository);

    expect(find.text('رسالة التوقيت'), findsOneWidget);
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('conversation opens on the newest message', (tester) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeCustomerRepository();
    repository.messages.addAll(_manyMessages(40));

    await _pumpChat(tester, repository);

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      scrollable.position.pixels,
      closeTo(scrollable.position.maxScrollExtent, 1),
    );
    expect(find.text('رسالة 40'), findsOneWidget);
    expect(find.text('رسالة 1'), findsNothing);
  });

  testWidgets('user scrolling towards older messages is preserved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeCustomerRepository();
    repository.messages.addAll(_manyMessages(40));

    await _pumpChat(tester, repository);

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      scrollable.position.pixels,
      closeTo(scrollable.position.maxScrollExtent, 1),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();

    final afterDrag = scrollable.position.pixels;
    expect(afterDrag, lessThan(scrollable.position.maxScrollExtent - 1));

    // No post-frame jump may pull the user back down after they scroll up.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(scrollable.position.pixels, closeTo(afterDrag, 0.5));
  });

  testWidgets('load failure shows the message and retry reloads', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'رسالة بعد إعادة المحاولة',
      ),
    );
    repository.conversationError = const ApiException(
      ServerFailure(code: 500, message: 'تعذر تحميل المحادثة من الخادم.'),
    );
    repository.failConversationCalls = 1;

    await _pumpChat(tester, repository);

    expect(find.text('تعذر تحميل المحادثة من الخادم.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('رسالة بعد إعادة المحاولة'), findsNothing);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }

    expect(repository.conversationCalls, 2);
    expect(find.text('رسالة بعد إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('send failure surfaces the API message', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'موجود',
      ),
    );
    repository.sendError = const ApiException(
      ServerFailure(code: 500, message: 'تعذّر إرسال الرسالة الآن.'),
    );

    await _pumpChat(tester, repository);

    await tester.enterText(find.byType(TextField), 'رسالة جديدة');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('تعذّر إرسال الرسالة الآن.'), findsOneWidget);
    expect(repository.sentBodies, ['رسالة جديدة']);
  });

  testWidgets('typed text is kept after a send failure', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'موجود',
      ),
    );
    repository.sendError = const ApiException(NetworkFailure());

    await _pumpChat(tester, repository);

    await tester.enterText(find.byType(TextField), 'نص يجب ألا يضيع');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'نص يجب ألا يضيع',
    );
    expect(find.text('تعذر الاتصال بالخادم. تحقق من الشبكة.'), findsOneWidget);
  });

  testWidgets('duplicate submits are ignored while a send is in flight', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.messages.add(
      _message(
        id: 'm1',
        senderId: 'u-prov',
        senderName: 'سالم المزود',
        body: 'موجود',
      ),
    );
    final gate = Completer<void>();
    repository.sendGate = gate;

    await _pumpChat(tester, repository);

    await tester.enterText(find.byType(TextField), 'مرحبا');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    // Second submit while the first API call is still pending.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(repository.sentBodies, ['مرحبا']);

    gate.complete();
    await tester.pumpAndSettle();

    expect(repository.sentBodies, ['مرحبا']);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
    expect(find.text('مرحبا'), findsOneWidget);
  });

  testWidgets('switching account shows no previous-account thread while B loads', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.addMessage(
      'u-a',
      _message(
        id: 'a1',
        senderId: 'u-prov',
        senderName: 'مزود A',
        body: 'رسالة خاصة بحساب A',
      ),
    );
    repository.addMessage(
      'u-b',
      _message(
        id: 'b1',
        senderId: 'u-prov',
        senderName: 'مزود B',
        body: 'رسالة خاصة بحساب B',
      ),
    );

    final harness = _harness(repository, account: 'u-a');
    await _pumpHarness(tester, harness.container);
    expect(find.text('رسالة خاصة بحساب A'), findsOneWidget);

    final gate = repository.gateConversation('u-b');
    repository.account = 'u-b';
    harness.auth.switchTo('u-b', 2);
    await tester.pump();
    await tester.pump();

    // While B's thread is in flight, A's messages are already gone and B's
    // are not shown yet.
    expect(find.text('رسالة خاصة بحساب A'), findsNothing);
    expect(find.text('رسالة خاصة بحساب B'), findsNothing);
    expect(repository.conversationRequests, [
      'u-a|conversation|c1',
      'u-b|conversation|c1',
    ]);

    gate.complete();
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }

    expect(find.text('رسالة خاصة بحساب B'), findsOneWidget);
    expect(find.text('رسالة خاصة بحساب A'), findsNothing);
  });

  testWidgets('B load failure never falls back to A messages', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.addMessage(
      'u-a',
      _message(
        id: 'a1',
        senderId: 'u-prov',
        senderName: 'مزود A',
        body: 'رسالة خاصة بحساب A',
      ),
    );
    repository.accountErrors['u-b|conversation|c1'] = const ApiException(
      ServerFailure(code: 503, message: 'تعذر تحميل محادثة B.'),
    );

    final harness = _harness(repository, account: 'u-a');
    await _pumpHarness(tester, harness.container);
    expect(find.text('رسالة خاصة بحساب A'), findsOneWidget);

    repository.account = 'u-b';
    harness.auth.switchTo('u-b', 2);
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }

    expect(find.text('تعذر تحميل محادثة B.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('رسالة خاصة بحساب A'), findsNothing);
    expect(
      repository.conversationRequests,
      ['u-a|conversation|c1', 'u-b|conversation|c1'],
    );
  });

  testWidgets('send from A finishing under B does not clear B input or reload', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.addMessage(
      'u-a',
      _message(
        id: 'a1',
        senderId: 'u-prov',
        senderName: 'مزود A',
        body: 'رسالة خاصة بحساب A',
      ),
    );
    repository.addMessage(
      'u-b',
      _message(
        id: 'b1',
        senderId: 'u-prov',
        senderName: 'مزود B',
        body: 'رسالة خاصة بحساب B',
      ),
    );

    final harness = _harness(repository, account: 'u-a');
    await _pumpHarness(tester, harness.container);
    expect(find.text('رسالة خاصة بحساب A'), findsOneWidget);

    repository.sendGate = Completer<void>();
    await tester.enterText(find.byType(TextField), 'نص أُرسل من A');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    for (var i = 0; i < 20 && repository.sendRequests.isEmpty; i++) {
      await tester.pump();
    }
    expect(repository.sendRequests, ['u-a|sendMessage|c1']);

    // The account changes while A's send is still in flight.
    repository.account = 'u-b';
    harness.auth.switchTo('u-b', 2);
    await tester.pump();
    await tester.pump();

    repository.sendGate!.complete();
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    // A's confirmation belongs to A: B's input is untouched and no reload or
    // duplicate send happens for B.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'نص أُرسل من A',
    );
    expect(repository.sentBodies, ['نص أُرسل من A']);
    expect(
      repository.conversationRequests.where((r) => r.startsWith('u-a|')),
      ['u-a|conversation|c1'],
    );
    expect(repository.accountMessages['u-b']!.map((m) => m['body']), isNot(
      contains('نص أُرسل من A'),
    ));
    expect(find.text('رسالة خاصة بحساب B'), findsOneWidget);
    expect(find.text('رسالة خاصة بحساب A'), findsNothing);
  });
}
