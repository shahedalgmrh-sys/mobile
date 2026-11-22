import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';


class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(customerFavoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: SafeArea(
        child: favs.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 200),
              SizedBox(height: 12),
              ShimmerCard(height: 200),
            ],
          ),
          error: (e, _) => _FavoritesError(
            onRetry: () => ref.invalidate(customerFavoritesProvider),
          ),
          data: (data) {
            final services = dataList(data['services'])
                .map(serviceFromJson)
                .toList();
            final providers = dataList(data['providers']);
            if (services.isEmpty && providers.isEmpty) {
              return const Center(
                child: EmptyState(
                  title: 'لا توجد عناصر مفضلة',
                  subtitle:
                      'اضغط على أيقونة القلب في أي خدمة لإضافتها هنا',
                  icon: Icons.favorite_border,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(customerFavoritesProvider),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (providers.isNotEmpty) ...[
                    const Text('المزودون المفضلون',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    for (final p in providers)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                                str(p['business_name'] ??
                                            asMap(p['user'])['name'],
                                        'م')
                                    .isNotEmpty
                                    ? str(p['business_name'] ??
                                        asMap(p['user'])['name'])[0]
                                    : 'م'),
                          ),
                          title: Text(
                              str(p['business_name'] ??
                                  asMap(p['user'])['name'],
                                  'مزود'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(
                              '★ ${str(p['average_rating'], '—')}'),
                          trailing: FavoriteToggleButton(
                            id: str(p['id']),
                            isProvider: true,
                          ),
                          onTap: () => _openProvider(context, ref, p),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  if (services.isNotEmpty) ...[
                    const Text('الخدمات المفضلة',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    for (final s in services)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: s,
                          onTap: () => _openService(context, ref, s),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Opens the details, then reconciles the list with the server in the
  /// background. The central favorites state already keeps both screens in
  /// sync while mounted; this covers changes made on the details screen and
  /// keeps the visible data (no loading flicker) if the refresh fails.
  Future<void> _openService(
    BuildContext context,
    WidgetRef ref,
    Service service,
  ) async {
    await context.push(
      '/home/services/${service.slug.isNotEmpty ? service.slug : service.id}',
      extra: service,
    );
    if (!context.mounted) return;
    await _refreshQuietly(ref);
  }

  Future<void> _openProvider(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> provider,
  ) async {
    await context.push('/home/providers/${provider['id']}');
    if (!context.mounted) return;
    await _refreshQuietly(ref);
  }

  Future<void> _refreshQuietly(WidgetRef ref) async {
    try {
      await ref.read(customerFavoritesProvider.notifier).refresh();
    } catch (_) {
      // The last successful list stays visible; pull-to-refresh can retry.
    }
  }
}

/// Error state with a clear message, an icon and a retry action so a failed
/// load is recoverable without leaving the screen.
class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: SahelColors.primary300,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل المفضلة',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: SahelColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تحقق من اتصالك بالشبكة ثم حاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: SahelColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SahelButton.soft(
              label: 'إعادة المحاولة',
              onTap: onRetry,
              width: 200,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
