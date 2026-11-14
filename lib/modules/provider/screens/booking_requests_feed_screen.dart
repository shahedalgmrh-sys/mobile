import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class BookingRequestsFeedScreen extends ConsumerWidget {
  const BookingRequestsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(
      providerBookingsProvider((status: 'pending', date: null)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الحجز')),
      body: SafeArea(
        child: pending.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 170),
              SizedBox(height: 12),
              ShimmerCard(height: 170),
            ],
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 56,
                  color: SahelColors.muted,
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => ref.invalidate(providerBookingsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(providerBookingsProvider),
            child: items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 56,
                              color: SahelColors.muted,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'لا توجد طلبات جديدة',
                              style: TextStyle(
                                color: SahelColors.muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _RequestCard(booking: items[i]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> booking;
  const _RequestCard({required this.booking});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
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

  Future<void> _act(String action) async {
    setState(() => _busy = true);
    final repo = ref.read(providerRepositoryProvider);
    final id = str(widget.booking['id']);
    try {
      if (action == 'accept') {
        await repo.acceptBooking(id);
      } else {
        final reason = await _askRejectReason();
        if (reason == null) return;
        await repo.rejectBooking(id, reason: reason);
      }
      ref.invalidate(providerBookingsProvider);
      ref.invalidate(providerDashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept' ? 'تم قبول الطلب' : 'تم رفض الطلب',
            ),
          ),
        );
        // After accepting, open the booking details view directly.
        if (action == 'accept') {
          context.push('/p/bookings/$id', extra: widget.booking);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_failureMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askRejectReason() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب الرفض (مطلوب)'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'اذكر سبب رفض الطلب — مطلوب من الخادم',
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
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final customer = asMap(b['customer'] ?? b['user']);
    final service = asMap(b['service']);
    final address = asMap(b['address']);
    final name = str(customer['name'], 'عميل');
    final loc = str(address['city'] ?? address['full_address'] ?? '');
    final svc = str(service['name'], 'خدمة');
    final time = [
      str(b['booking_date']),
      str(b['booking_time'] ?? b['time_slot']),
    ].where((e) => e.isNotEmpty).join(' · ');
    final price = str(b['formatted_total'] ?? b['total']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '؟')),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (loc.isNotEmpty)
                      Text(
                        loc,
                        style: const TextStyle(
                          color: SahelColors.muted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              BookingStatusPill(
                status: BookingStatusX.fromJson(str(b['status'], 'pending')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SahelColors.slate50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_repair_service,
                  color: SahelColors.primary600,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svc,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: const TextStyle(
                            color: SahelColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: SahelColors.primary700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SahelButton.soft(
                  label: 'رفض',
                  onTap: _busy ? null : () => _act('reject'),
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _busy
                    ? const SizedBox(
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : SahelButton(
                        label: 'قبول الطلب',
                        variant: SahelButtonVariant.gradient,
                        onPressed: () => _act('accept'),
                        height: 40,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
