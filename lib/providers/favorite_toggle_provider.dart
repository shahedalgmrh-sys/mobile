import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/repositories/parsers.dart';
import 'auth_provider.dart';
import 'data_providers.dart';

/// Shared favorite-toggle state.
///
/// [pending] holds `account|type:id` keys with a request in flight, so the
/// same account cannot toggle one item twice from different buttons/screens.
/// Different accounts never share a key: a request that is still running when
/// the previous user logs out cannot block the next user.
///
/// [confirmed] holds `sessionKey|type:id` keys with the boolean returned by
/// the server until the favorites list catches up. Because the key contains
/// the login-session identity, a value confirmed for one account/session is
/// never reused for another.
class FavoriteToggleState {
  const FavoriteToggleState({
    this.pending = const <String>{},
    this.confirmed = const <String, bool>{},
  });

  final Set<String> pending;
  final Map<String, bool> confirmed;

  bool isPending(String key) => pending.contains(key);

  bool? confirmedFor(String key) => confirmed[key];

  FavoriteToggleState copyWith({
    Set<String>? pending,
    Map<String, bool>? confirmed,
  }) => FavoriteToggleState(
    pending: pending ?? this.pending,
    confirmed: confirmed ?? this.confirmed,
  );
}

/// App-wide coordinator for favorites. Keys are built from the account
/// session plus `service:{id}` or `provider:{id}`; toggles for different
/// items or accounts stay independent.
class FavoriteToggleController extends StateNotifier<FavoriteToggleState> {
  FavoriteToggleController(this._ref) : super(const FavoriteToggleState());

  final Ref _ref;

  /// Depth of list refreshes started by a toggle itself. Internal refreshes
  /// reconcile against the server value, so they must not be treated as the
  /// authoritative external refreshes that invalidate cached confirmations.
  int _selfRefreshDepth = 0;

  /// Locks are account-scoped but not session-scoped on purpose: while a
  /// request for an account+item is still running, that same account must not
  /// start a second toggle (even after re-login), otherwise the two responses
  /// could flip the server state twice. Other accounts use another key and are
  /// never blocked.
  static String pendingKeyFor(
    SessionScope session, {
    required bool isProvider,
    required String id,
  }) =>
      '${session.userId ?? 'guest'}|'
      '${isProvider ? 'provider' : 'service'}:$id';

  /// Confirmed values belong to one exact session, so a same-user re-login
  /// starts from the server state instead of inheriting the old response.
  static String confirmedKeyFor(
    SessionScope session, {
    required bool isProvider,
    required String id,
  }) =>
      '${session.key}|${isProvider ? 'provider' : 'service'}:$id';

  /// Drops confirmed values that belong to any previous session. Pending
  /// locks are intentionally kept: their request is still running and its
  /// `finally` releases the lock; dropping it early would allow an unsafe
  /// duplicate toggle for the same account+item.
  void onSessionChanged(SessionScope next) {
    if (!mounted) return;
    final prefix = '${next.key}|';
    final kept = <String, bool>{
      for (final entry in state.confirmed.entries)
        if (entry.key.startsWith(prefix)) entry.key: entry.value,
    };
    if (kept.length != state.confirmed.length) {
      state = state.copyWith(confirmed: kept);
    }
  }

  /// A successful list refresh that did not originate from a toggle is
  /// authoritative: the stale cached confirmation must not keep overriding
  /// newer server data. This is what reconciles the heart after a toggle's
  /// own follow-up refresh failed and a later pull-to-refresh returned a
  /// different list.
  ///
  /// Failed or loading states never touch cached confirmations, and values
  /// from another session are never considered.
  void onFavoritesChanged(AsyncValue<Map<String, dynamic>> next) {
    if (!mounted || _selfRefreshDepth > 0) return;
    if (next.isLoading || next.hasError) return;
    final data = next.valueOrNull;
    if (data == null) return;
    final session = _ref.read(sessionScopeProvider);
    if (!session.hasSession) return;

    final prefix = '${session.key}|';
    final kept = <String, bool>{
      for (final entry in state.confirmed.entries)
        if (!entry.key.startsWith(prefix)) entry.key: entry.value,
    };
    if (kept.length != state.confirmed.length) {
      state = state.copyWith(confirmed: kept);
    }
  }

  /// Toggles the favorite and returns the state confirmed by the API.
  /// Returns `null` when the same account+item already has a request in
  /// flight.
  Future<bool?> toggle({required bool isProvider, required String id}) async {
    final session = _ref.read(sessionScopeProvider);
    final pendingKey = pendingKeyFor(
      session,
      isProvider: isProvider,
      id: id,
    );
    if (state.isPending(pendingKey)) return null;

    final confirmedKey = confirmedKeyFor(
      session,
      isProvider: isProvider,
      id: id,
    );

    state = state.copyWith(pending: {...state.pending, pendingKey});
    try {
      final repository = _ref.read(customerRepositoryProvider);
      final favorited = isProvider
          ? await repository.toggleProviderFavorite(id)
          : await repository.toggleServiceFavorite(id);
      if (!mounted) return favorited;

      // The session may have ended (logout, account switch or same-user
      // re-login) while the request was running. A successful old response
      // must still be discarded: it belongs to nobody in the current UI.
      if (!_ref.read(sessionScopeProvider).sameSession(session)) {
        return favorited;
      }

      // Reflect the confirmed server value immediately; the refresh below
      // only reconciles it with the shared favorites list.
      state = state.copyWith(confirmed: {...state.confirmed, confirmedKey: favorited});

      // The refresh below belongs to this toggle: while it runs, an incoming
      // list state is not an external refresh and must not invalidate the
      // confirmation (that would cause a visible flicker).
      _selfRefreshDepth++;
      try {
        final favorites = await _ref
            .read(customerFavoritesProvider.notifier)
            .refresh(expectedSession: session);
        if (!mounted || favorites == null) return favorited;
        if (!_ref.read(sessionScopeProvider).sameSession(session)) {
          return favorited;
        }
        final bucket = dataList(
          favorites[isProvider ? 'providers' : 'services'],
        );
        final listed = bucket.any((item) => str(item['id']) == id);
        if (listed == favorited) {
          // The list agrees with the server, so it becomes the source again.
          state = state.copyWith(confirmed: {...state.confirmed}..remove(confirmedKey));
        }
      } catch (_) {
        // The toggle itself succeeded; a failed refresh must not be reported
        // as a failed toggle, and the confirmed value stays authoritative.
      } finally {
        _selfRefreshDepth--;
      }
      return favorited;
    } finally {
      if (mounted) {
        state = state.copyWith(pending: {...state.pending}..remove(pendingKey));
      }
    }
  }
}

final favoriteToggleControllerProvider =
    StateNotifierProvider<FavoriteToggleController, FavoriteToggleState>((ref) {
      final controller = FavoriteToggleController(ref);
      ref.listen<SessionScope>(sessionScopeProvider, (previous, next) {
        controller.onSessionChanged(next);
      });
      ref.listen<AsyncValue<Map<String, dynamic>>>(customerFavoritesProvider, (
        previous,
        next,
      ) {
        controller.onFavoritesChanged(next);
      });
      return controller;
    });
