import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
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
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(customerFavoritesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
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
                          onTap: () => context
                              .push('/home/providers/${p['id']}'),
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
                          onTap: () => context.push(
                              '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                              extra: s),
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
}
