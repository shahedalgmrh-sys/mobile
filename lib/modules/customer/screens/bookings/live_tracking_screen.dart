import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class LiveTrackingScreen extends ConsumerWidget {
  final String id;
  const LiveTrackingScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = id;
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
  final String bookingId;
  const _TrackingBody({required this.track, required this.bookingId});

  String _stepTime(Map<String, dynamic> step) {
    final raw = step['time'] ?? step['at'];
    final formatted = formatDateTime(raw);
    return formatted.isNotEmpty ? formatted : str(raw);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Newer API shape (rahma's backend): booking + provider_location +
    // destination. Legacy keys (provider/provider_lat/steps) still honored
    // so the screen works against either shape.
    final booking = asMap(track['booking']);
    final legacyProvider = asMap(track['provider']);
    final provider =
        legacyProvider.isNotEmpty ? legacyProvider : asMap(booking['provider']);
    final providerUser = asMap(provider['user']);
    final providerLoc = asMap(track['provider_location']);
    final providerLat =
        toDoubleOrNull(track['provider_lat'] ?? providerLoc['latitude']);
    final providerLng =
        toDoubleOrNull(track['provider_lng'] ?? providerLoc['longitude']);
    final dest = asMap(track['destination']);
    final destLat = toDoubleOrNull(dest['latitude']);
    final destLng = toDoubleOrNull(dest['longitude']);
    final eta = toIntOrNull(track['eta_minutes']);
    final status = str(track['status'] ??
        track['current_status'] ??
        booking['status']);
    final statusLabel = BookingStatusX.fromJson(status).displayNameAr;
    final phone = str(providerUser['phone'] ?? provider['phone']);
    final legacySteps = asMapList(track['steps']);
    // The current backend sends the booking timeline instead of prepared
    // steps; project it onto the stepper so every past event renders with
    // a check.
    final steps = legacySteps.isNotEmpty
        ? legacySteps
        : asMapList(booking['timeline'])
            .map((h) => <String, dynamic>{
                  'label': BookingStatusX.fromJson(str(h['new_status']))
                      .displayNameAr,
                  'time': formatDateTime(h['created_at']),
                  'done': true,
                })
            .toList();
    final config = ref.watch(appConfigProvider);

    return Stack(
      children: [
        // ---------------------------------------------------------- map
        _TrackingMap(
          apiKey: config.googleMapsApiKey,
          providerLat: providerLat,
          providerLng: providerLng,
          destLat: destLat,
          destLng: destLng,
          destAddress: str(dest['address']),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: SahelRadii.pillRadius,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: SahelColors.surface,
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
              borderRadius: SahelRadii.pillRadius,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: SahelColors.surface,
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
            shadowColor: SahelColors.text.withValues(alpha: 0.2),
            margin: EdgeInsets.zero,
            shape:
                const RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
            color: SahelColors.surface,
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
                              : 'حالة الحجز: $statusLabel',
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
                              _stepTime(s),
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
                          onPressed: () => context.go('/inbox'),
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

/// Real Google map of the tracking session. When the API key (or the
/// provider coordinates) are missing it degrades to the informative
/// placeholder instead of rendering blank tiles.
class _TrackingMap extends StatelessWidget {
  final String apiKey;
  final double? providerLat;
  final double? providerLng;
  final double? destLat;
  final double? destLng;
  final String destAddress;

  const _TrackingMap({
    required this.apiKey,
    required this.providerLat,
    required this.providerLng,
    required this.destLat,
    required this.destLng,
    required this.destAddress,
  });

  bool get _canRender =>
      apiKey.isNotEmpty && providerLat != null && providerLng != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SahelColors.primary50,
      child: _canRender
          ? _buildGoogleMap()
          : SizedBox.expand(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          color: SahelColors.primary200, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        providerLat != null
                            ? 'موقع الفني: ${providerLat!.toStringAsFixed(4)}, ${providerLng?.toStringAsFixed(4)}'
                            : 'بانتظار تحديث موقع الفني…',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SahelColors.primary700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGoogleMap() {
    final providerPos = LatLng(providerLat!, providerLng!);
    final hasDest = destLat != null && destLng != null;

    // Center between both points when the destination is known, otherwise
    // sit on the provider location at a comfortable zoom.
    final mid = hasDest
        ? LatLng((providerLat! + destLat!) / 2, (providerLng! + destLng!) / 2)
        : providerPos;

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: mid, zoom: 14),
      markers: {
        Marker(
          markerId: const MarkerId('provider'),
          position: providerPos,
          infoWindow: const InfoWindow(title: 'موقع الفني'),
        ),
        if (hasDest)
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(destLat!, destLng!),
            infoWindow: InfoWindow(title: 'عنوان الحجز', snippet: destAddress),
          ),
      },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
