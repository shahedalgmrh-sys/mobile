import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/providers/data_providers.dart';

/// Heart that toggles a service or provider favorite via the real
/// `/customer/favorites/toggle` endpoints and reflects the shared
/// [customerFavoritesProvider] state.
class FavoriteToggleButton extends ConsumerStatefulWidget {
  final bool isProvider;
  final String id;
  final Color? backgroundColor;
  const FavoriteToggleButton({
    super.key,
    required this.id,
    this.isProvider = false,
    this.backgroundColor,
  });

  @override
  ConsumerState<FavoriteToggleButton> createState() =>
      _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends ConsumerState<FavoriteToggleButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(customerFavoritesProvider).valueOrNull;
    final bucket =
        favorites == null ? [] : dataList(favorites[widget.isProvider ? 'providers' : 'services']);
    final isFavorite = bucket.any((f) => str(f['id']) == widget.id);

    return IconButton(
      tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
      onPressed: _busy ? null : () => _toggle(),
      style: widget.backgroundColor == null
          ? null
          : IconButton.styleFrom(backgroundColor: widget.backgroundColor),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? SahelColors.rose : null,
      ),
    );
  }

  Future<void> _toggle() async {
    setState(() => _busy = true);
    final repo = ref.read(customerRepositoryProvider);
    try {
      if (widget.isProvider) {
        await repo.toggleProviderFavorite(widget.id);
      } else {
        await repo.toggleServiceFavorite(widget.id);
      }
      ref.invalidate(customerFavoritesProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('تعذر تحديث المفضلة — حاول مجدداً')),
          );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
