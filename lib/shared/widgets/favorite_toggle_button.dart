import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart'
    show ApiException;
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/favorite_toggle_provider.dart';

/// Heart that toggles a service or provider favorite via the real
/// `/customer/favorites/toggle` endpoints and reflects the shared
/// [customerFavoritesProvider] state.
///
/// The API is a blind toggle (no desired state), so an unknown list state must
/// never be treated as "not favorited". While the first list load is running
/// or has failed the button is disabled and sends no request; it only becomes
/// interactive once a confirmed list is available.
///
/// The in-flight guard lives in [favoriteToggleControllerProvider], so every
/// button for the same item (even on another screen) is disabled while that
/// item's request runs, while other items stay interactive.
class FavoriteToggleButton extends ConsumerWidget {
  final bool isProvider;
  final String id;
  final Color? backgroundColor;

  /// Optional square hit area. `null` keeps the standard Material size
  /// (48dp); cards pass a compact size for the media overlay heart.
  final double? size;

  const FavoriteToggleButton({
    super.key,
    required this.id,
    this.isProvider = false,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionScopeProvider);
    final favoritesAsync = ref.watch(customerFavoritesProvider);
    final favorites = favoritesAsync.valueOrNull;

    // Unknown state: the list has never loaded (or its load failed). A toggle
    // sent from here could invert the user's real intent, so it is blocked.
    final isUnknown = favorites == null;
    final isListLoading = isUnknown && favoritesAsync.isLoading;
    final isListError = isUnknown && favoritesAsync.hasError;

    final bucket = favorites == null
        ? const <Map<String, dynamic>>[]
        : dataList(favorites[isProvider ? 'providers' : 'services']);
    final pendingKey = FavoriteToggleController.pendingKeyFor(
      session,
      isProvider: isProvider,
      id: id,
    );
    final confirmedKey = FavoriteToggleController.confirmedKeyFor(
      session,
      isProvider: isProvider,
      id: id,
    );
    final toggleState = ref.watch(favoriteToggleControllerProvider);
    final isBusy = toggleState.isPending(pendingKey);
    // A server-confirmed result wins until the shared list catches up. With an
    // unknown list and no confirmation the icon stays empty but disabled.
    final isFavorite =
        toggleState.confirmedFor(confirmedKey) ??
        (isUnknown
            ? false
            : bucket.any((favorite) => str(favorite['id']) == id));
    final isDisabled = isBusy || isUnknown;

    final String tooltip;
    if (isListLoading) {
      tooltip = 'جارٍ تحميل المفضلة';
    } else if (isListError) {
      tooltip = 'تعذر تحميل المفضلة';
    } else if (isBusy) {
      tooltip = 'جارٍ تحديث المفضلة…';
    } else {
      tooltip = isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة';
    }

    final iconSize = size == null ? 24.0 : size! * 0.56;
    Widget icon;
    if (isBusy) {
      final indicator = size == null ? 20.0 : size! * 0.55;
      icon = SizedBox(
        width: indicator,
        height: indicator,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      final heart = Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: iconSize,
        color: isFavorite
            ? SahelColors.rose
            : (backgroundColor == null ? null : SahelColors.onPrimary),
      );
      // Loading or failed list: a faded heart makes "not interactive yet"
      // visible without pretending the item is not a favorite.
      icon = isUnknown ? Opacity(opacity: 0.45, child: heart) : heart;
    }

    final button = IconButton(
      tooltip: tooltip,
      onPressed: isDisabled ? null : () => _toggle(context, ref),
      padding: size == null ? null : EdgeInsets.zero,
      constraints: size == null
          ? null
          : BoxConstraints.tightFor(width: size, height: size),
      style: backgroundColor == null
          ? null
          : IconButton.styleFrom(backgroundColor: backgroundColor),
      icon: icon,
    );

    if (!isDisabled) return button;

    // A disabled IconButton ignores pointers, so without this guard a tap on
    // the blocked heart would fall through to the surrounding card and open
    // its details. The heart owns its hit area in every state.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: button,
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      // `null` means another button already has this item in flight.
      await ref
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: isProvider, id: id);
    } catch (error) {
      if (messenger != null) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(_favoriteErrorMessage(error))));
      }
    }
  }
}

/// Surfaces the API/validation message when available so failures are
/// actionable instead of a generic retry prompt.
String _favoriteErrorMessage(Object error) {
  if (error is InvalidFavoriteResponseException) {
    return 'تعذر التحقق من حالة المفضلة من الخادم. حاول مجدداً.';
  }
  if (error is ApiException) {
    final failure = error.failure;
    if (failure is ServerFailure) {
      final message = failure.message.trim();
      return message.isNotEmpty ? message : 'تعذر تحديث المفضلة — حاول مجدداً';
    }
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
    }
    if (failure is UnauthorizedFailure) {
      return 'انتهت الجلسة. سجّل الدخول مجدداً.';
    }
    if (failure is ValidationFailure) {
      final messages = failure.errors.values
          .expand((list) => list)
          .where((message) => message.trim().isNotEmpty);
      if (messages.isNotEmpty) return messages.join('\n');
    }
  }
  return 'تعذر تحديث المفضلة — حاول مجدداً';
}
