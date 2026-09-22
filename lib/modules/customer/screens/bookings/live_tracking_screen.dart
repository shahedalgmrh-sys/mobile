import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class LiveTrackingScreen extends ConsumerWidget {
  final String id;
  const LiveTrackingScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = int.tryParse(id) ?? 0;
    final track = ref.watch(bookingTrackProvider(bookingId));

    return Scaffold(
      body: track.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SahelColors.primary600),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined,
                  size: 56, color: SahelColors.textMuted),
              const SizedBox(height: 12),
              const Text('التتبع غير متاح حالياً',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SahelColors.textMuted)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(bookingTrackProvider(bookingId)),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
        data: (t) => _TrackingBody(track: t, bookingId: bookingId),
      ),
    );
  }
}

class _TrackingBody extends ConsumerWidget {
  final Map<String, dynamic> track;
  final int bookingId;
  const _TrackingBody({required this.track, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = asMap(track['provider']);
    final providerUser = asMap(provider['user']);
    final providerLat = toDoubleOrNull(track['provider_lat']);
    final providerLng = toDoubleOrNull(track['provider_lng']);
    final eta = toIntOrNull(track['eta_minutes']);
    final status = str(track['status']);
    final phone = str(providerUser['phone'] ?? provider['phone']);
    final steps = asMapList(track['steps']);

    return Stack(
      children: [
        Container(
          color: SahelColors.primary50,
          child: SizedBox.expand(
            child: Placeholder(
              color: SahelColors.primary200,
              fallbackWidth: 300,
              fallbackHeight: 300,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    providerLat != null
                        ? 'موقع الفني: ${providerLat.toStringAsFixed(4)}, ${providerLng?.toStringAsFixed(4)}'
                        : 'بانتظار تحديث موقع الفني…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SahelColors.primary700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: SahelColors.shadowSm,
                        blurRadius: 4,
                        offset: Offset(0, 1))
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: SahelColors.text),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: InkWell(
              onTap: () => ref.invalidate(bookingTrackProvider(bookingId)),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: SahelColors.shadowSm,
                        blurRadius: 4,
                        offset: Offset(0, 1))
                  ],
                ),
                child:
                    const Icon(Icons.refresh, color: SahelColors.primary700),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Card(
            elevation: 24,
            shadowColor: SahelColors.text.withOpacity(0.2),
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: SahelColors.primary700, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status == 'in_progress'
                              ? 'الفني في الطريق…'
                              : 'حالة الحجز: $status',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (eta != null)
                        Chip(
                          label: Text(
                            'يصل خلال: $eta دقائق',
                            style: const TextStyle(
                                color: SahelColors.amber700,
                                fontWeight: FontWeight.w800,
                                fontSize: 12),
                          ),
                          backgroundColor: SahelColors.amberSoft,
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProviderMiniCard(
                    businessName: str(provider['business_name'] ??
                        providerUser['name']),
                    avatarUrl: strOrNull(provider['business_logo'] ??
                        providerUser['avatar']),
                    ratingAvg:
                        toDoubleOrNull(provider['average_rating']),
                    isVerified: toBool(provider['is_verified']),
                  ),
                  if (steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    for (final s in steps)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(
                              toBool(s['done'] ?? s['completed'])
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color:
                                  toBool(s['done'] ?? s['completed'])
                                      ? SahelColors.success
                                      : SahelColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                str(s['label'] ?? s['title']),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              str(s['time'] ?? s['at']),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: SahelColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (phone.isNotEmpty)
                        Expanded(
                          child: SahelButton.soft(
                            icon: Icons.call,
                            label: 'اتصال سريع',
                            onPressed: () async {
                              final tel = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(tel)) {
                                await launchUrl(tel);
                              }
                            },
                          ),
                        ),
                      if (phone.isNotEmpty) const SizedBox(width: 12),
                      Expanded(
                        child: SahelButton.soft(
                          icon: Icons.chat,
                          label: 'مراسلة',
                          onPressed: () {},
                        ),
                      ),
                      if (providerLat != null &&
                          providerLng != null) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 48,
                          child: SahelButton.gradient(
                            icon: Icons.navigation,
                            label: '',
                            onPressed: () async {
                              final maps = Uri.parse(
                                  'https://maps.google.com/?q=$providerLat,$providerLng');
                              if (await canLaunchUrl(maps)) {
                                await launchUrl(maps);
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
