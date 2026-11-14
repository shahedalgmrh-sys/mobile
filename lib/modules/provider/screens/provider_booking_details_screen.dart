import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/repositories/provider_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/booking_status_stepper.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class ProviderBookingDetailsScreen extends ConsumerWidget {
  final String id;

  const ProviderBookingDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = id;
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
  final String bookingId;
  const _Body({required this.booking, required this.bookingId});

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  String _failureMessage(Object e) {
    if (e is ApiException) {
      final failure = e.failure;
      if (failure is ServerFailure) return failure.message;
      if (failure is ValidationFailure) {
        return failure.errors.values.expand((items) => items).join('\n');
      }
    }
    return 'تعذر تنفيذ العملية';
  }

  Future<void> _act(Future<Map<String, dynamic>> Function() call) async {
    setState(() => _busy = true);
    try {
      await call();
      ref.invalidate(providerBookingProvider(widget.bookingId));
      ref.invalidate(providerBookingsProvider);
      ref.invalidate(providerDashboardProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_failureMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject(ProviderRepository repo, String id) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب رفض الحجز (مطلوب)'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اذكر سبب الرفض — مطلوب من الخادم',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => FilledButton(
              onPressed: value.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, value.text.trim()),
              child: const Text('تأكيد الرفض'),
            ),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await _act(() => repo.rejectBooking(id, reason: reason));
  }

  /// Mirrors the server rule: cancellation requires a reason (≤500 chars)
  /// and is refused for completed/cancelled/rejected bookings server-side.
  Future<void> _cancelBooking(ProviderRepository repo, String id) async {
    final controller = TextEditingController();
    String? reason;
    var confirmed = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('إلغاء الحجز'),
          content: TextField(
            controller: controller,
            maxLength: 500,
            maxLines: 3,
            onChanged: (v) => setDialog(() => reason = v.trim()),
            decoration: const InputDecoration(hintText: 'سبب الإلغاء (مطلوب)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: reason == null || reason!.isEmpty
                  ? null
                  : () {
                      confirmed = true;
                      Navigator.pop(ctx);
                    },
              child: const Text(
                'تأكيد الإلغاء',
                style: TextStyle(color: SahelColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
    if (!confirmed) return;
    await _act(() => repo.cancelBooking(id, reason ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final repo = ref.read(providerRepositoryProvider);
    final status = BookingStatusX.fromJson(str(b['status'], 'pending'));
    final service = asMap(b['service']);
    final customer = asMap(b['customer'] ?? b['user']);
    final address = asMap(b['address']);
    // BookingResource does not serialize the customer/user object; only the
    // address phone is available for contact. The name stays a generic label.
    final phone = str(customer['phone'] ?? address['phone']);
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
              const Text(
                'تفاصيل الخدمة',
                style: TextStyle(
                  color: SahelColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                str(service['name'], 'خدمة'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                [
                  str(b['booking_date']),
                  str(b['booking_time'] ?? b['time_slot']),
                ].where((e) => e.isNotEmpty).join(' · '),
                style: const TextStyle(color: SahelColors.muted, fontSize: 13),
              ),
              if (str(address['full_address'] ?? address['address'])
                  .isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  str(address['full_address'] ?? address['address']),
                  style: const TextStyle(
                    color: SahelColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'العميل',
                style: TextStyle(
                  color: SahelColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(child: Text(str(customer['name'], 'ع')[0])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          str(customer['name'], 'عميل'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (phone.isNotEmpty)
                          Text(
                            phone,
                            style: const TextStyle(
                              color: SahelColors.muted,
                              fontSize: 12,
                            ),
                          ),
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
                        child: Icon(
                          Icons.phone,
                          color: SahelColors.primary700,
                          size: 18,
                        ),
                      ),
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
              const Text(
                'المبلغ المستحق',
                style: TextStyle(color: SahelColors.muted),
              ),
              const Spacer(),
              Text(
                str(b['formatted_total'] ?? b['total'], '—'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: SahelColors.primary700,
                ),
              ),
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
                    onTap: () => _reject(repo, id),
                    height: 46,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SahelButton(
                    label: 'قبول',
                    variant: SahelButtonVariant.gradient,
                    onPressed: () => _act(() => repo.acceptBooking(id)),
                    height: 46,
                  ),
                ),
              ],
            ),
          ],
          if (status == BookingStatus.pending ||
              status == BookingStatus.accepted)
            TextButton.icon(
              onPressed: () => _cancelBooking(repo, id),
              icon: const Icon(Icons.close, color: SahelColors.danger),
              label: const Text(
                'إلغاء الحجز',
                style: TextStyle(color: SahelColors.danger),
              ),
            ),
          if (status == BookingStatus.accepted)
            SahelButton(
              label: 'بدء التنفيذ',
              variant: SahelButtonVariant.amber,
              onPressed: () => _act(() => repo.startBooking(id)),
              height: 46,
            ),
          if (status == BookingStatus.inProgress)
            SahelButton(
              label: 'إنهاء الحجز',
              variant: SahelButtonVariant.filled,
              onPressed: () => _act(() => repo.completeBooking(id)),
              height: 46,
            ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: child,
    );
  }
}
