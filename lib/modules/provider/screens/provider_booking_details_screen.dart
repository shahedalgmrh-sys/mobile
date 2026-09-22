import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/booking_stepper.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../models/booking_status.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderBookingDetailsScreen extends ConsumerWidget {
  final String id;

  const ProviderBookingDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = int.tryParse(id) ?? 0;
    final booking = ref.watch(providerBookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: Text('الحجز #$id')),
      body: SafeArea(
        child: booking.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 90),
              SizedBox(height: 12),
              ShimmerCard(height: 130),
              SizedBox(height: 12),
              ShimmerCard(height: 90),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(providerBookingProvider(bookingId)),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (b) => _Body(booking: b, bookingId: bookingId),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;
  final int bookingId;
  const _Body({required this.booking, required this.bookingId});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  Future<void> _act(Future<Map<String, dynamic>> Function() call) async {
    setState(() => _busy = true);
    try {
      await call();
      ref.invalidate(providerBookingProvider(widget.bookingId));
      ref.invalidate(providerBookingsProvider);
      ref.invalidate(providerDashboardProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تنفيذ العملية')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final repo = ref.read(providerRepositoryProvider);
    final status =
        BookingStatusX.fromJson(str(b['status'], 'pending'));
    final service = asMap(b['service']);
    final customer = asMap(b['customer'] ?? b['user']);
    final address = asMap(b['address']);
    final phone = str(customer['phone']);
    final id = widget.bookingId;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BookingStatusStepper(status: status),
        const SizedBox(height: 24),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تفاصيل الخدمة',
                  style: TextStyle(
                      color: SahelColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(str(service['name'], 'خدمة'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                [
                  str(b['booking_date']),
                  str(b['booking_time'] ?? b['time_slot']),
                ].where((e) => e.isNotEmpty).join(' · '),
                style: const TextStyle(
                    color: SahelColors.muted, fontSize: 13),
              ),
              if (str(address['full_address'] ?? address['address'])
                  .isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(str(address['full_address'] ?? address['address']),
                    style: const TextStyle(
                        color: SahelColors.muted, fontSize: 13)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('العميل',
                  style: TextStyle(
                      color: SahelColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                      child: Text(
                          str(customer['name'], 'ع').isNotEmpty
                              ? str(customer['name'])[0]
                              : 'ع')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(str(customer['name'], 'عميل'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        if (phone.isNotEmpty)
                          Text(phone,
                              style: const TextStyle(
                                  color: SahelColors.muted,
                                  fontSize: 12)),
                      ],
                    ),
                  ),
                  if (phone.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        final tel = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(tel)) {
                          await launchUrl(tel);
                        }
                      },
                      child: const CircleAvatar(
                          backgroundColor: SahelColors.primary100,
                          child: Icon(Icons.phone,
                              color: SahelColors.primary700,
                              size: 18)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          Row(
            children: [
              const Text('المبلغ المستحق',
                  style: TextStyle(color: SahelColors.muted)),
              const Spacer(),
              Text(
                  str(b['formatted_total'] ?? b['total'], '—'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: SahelColors.primary700)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          if (status == BookingStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: SahelButton.soft(
                      label: 'رفض الحجز',
                      onTap: () => _act(() => repo.rejectBooking(id)),
                      height: 46),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SahelButton(
                      label: 'قبول',
                      variant: SahelButtonVariant.gradient,
                      onPressed: () => _act(() => repo.acceptBooking(id)),
                      height: 46),
                ),
              ],
            ),
          ],
          if (status == BookingStatus.accepted)
            SahelButton(
                label: 'بدء التنفيذ',
                variant: SahelButtonVariant.amber,
                onPressed: () => _act(() => repo.startBooking(id)),
                height: 46),
          if (status == BookingStatus.inProgress)
            SahelButton(
                label: 'إنهاء الحجز',
                variant: SahelButtonVariant.filled,
                onPressed: () => _act(() => repo.completeBooking(id)),
                height: 46),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: child,
    );
  }
}
