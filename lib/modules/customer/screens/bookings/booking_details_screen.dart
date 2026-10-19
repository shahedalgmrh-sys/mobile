import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/booking_status_pill.dart';
import 'package:saber_flutter/shared/widgets/booking_status_stepper.dart';
import 'package:saber_flutter/shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class BookingDetailsScreen extends ConsumerWidget {
  final String id;
  const BookingDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingId = id;
    final booking = ref.watch(customerBookingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الحجز #$id',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          booking.maybeWhen(
            data: (b) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: BookingStatusPill(
                status:
                    BookingStatusX.fromJson(str(b['status'], 'pending')),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: booking.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ShimmerCard(height: 90),
            SizedBox(height: 16),
            ShimmerCard(height: 220),
            SizedBox(height: 16),
            ShimmerCard(height: 160),
          ],
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 56, color: SahelColors.textMuted),
              const SizedBox(height: 12),
              const Text('تعذر تحميل تفاصيل الحجز',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SahelColors.textMuted)),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(customerBookingProvider(bookingId)),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (b) => _BookingDetailsBody(booking: b, bookingId: bookingId),
      ),
    );
  }
}

class _BookingDetailsBody extends ConsumerWidget {
  final Map<String, dynamic> booking;
  final String bookingId;
  const _BookingDetailsBody({required this.booking, required this.bookingId});

  static const titleSmall = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w700, color: SahelColors.text);
  static const bodySmall = TextStyle(
      fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w500);
  static const muted = TextStyle(
      color: SahelColors.textMuted,
      fontWeight: FontWeight.w500,
      fontSize: 13);
  static const amountStyle = TextStyle(
      fontWeight: FontWeight.w700, fontSize: 13, color: SahelColors.text);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = BookingStatusX.fromJson(str(booking['status'], 'pending'));
    final service = asMap(booking['service']);
    final provider = asMap(booking['provider']);
    final providerUser = asMap(provider['user']);
    final address = asMap(booking['address']);
    final images = asList(booking['images'] ?? booking['attachments']);
    final isPaid = toBool(booking['is_paid']) || status == BookingStatus.paid;
    final canCancel = status == BookingStatus.pending ||
        status == BookingStatus.accepted;
    final canTrack = status == BookingStatus.accepted ||
        status == BookingStatus.inProgress;
    final phone = str(providerUser['phone'] ?? provider['phone']);

    final addressText = str(address['full_address'] ??
        address['address'] ??
        booking['address_text'] ??
        booking['address']);

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(customerBookingProvider(bookingId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingStatusStepper(status: status),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: SahelRadii.lgRadius,
              side: const BorderSide(color: SahelColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('الخدمة',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      Text(
                        str(service['name'], '—'),
                        style: const TextStyle(
                            color: SahelColors.primary700,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('موعد التنفيذ',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      Text(
                        [
                          str(booking['booking_date']),
                          str(booking['booking_time'] ??
                              booking['time_slot']),
                        ].where((e) => e.isNotEmpty).join(' · '),
                        style: const TextStyle(
                            color: SahelColors.primary700,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الفني المكلف',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      ProviderMiniCard(
                        businessName: str(provider['business_name'] ??
                            providerUser['name']),
                        avatarUrl:
                            strOrNull(provider['business_logo'] ??
                                providerUser['avatar']),
                        ratingAvg:
                            toDoubleOrNull(provider['average_rating']),
                        isVerified: toBool(provider['is_verified']),
                      ),
                    ],
                  ),
                  if (addressText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: SahelColors.primary600, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            addressText,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: SahelColors.text),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (str(booking['notes'] ?? booking['customer_notes'])
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('ملاحظات العميل:', style: titleSmall),
                    const SizedBox(height: 4),
                    Text(
                        str(booking['notes'] ?? booking['customer_notes']),
                        style: bodySmall),
                  ],
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('الصور المرفقة:', style: titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: images.map((img) {
                        final url = str(asMap(img)['url'] ?? img);
                        return ClipRRect(
                          borderRadius: SahelRadii.smRadius,
                          child: url.isNotEmpty
                              ? Image.network(
                                  url,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _imgPlaceholder(),
                                )
                              : _imgPlaceholder(),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('الإجراءات السريعة',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      if (canTrack)
                        SahelButton.gradient(
                          icon: Icons.map,
                          label: 'تتبع الوصول',
                          width: 150,
                          onPressed: () =>
                              context.push('/bookings/$bookingId/track'),
                        ),
                      if (phone.isNotEmpty)
                        SahelButton.soft(
                          icon: Icons.call,
                          label: 'اتصال',
                          width: 120,
                          onPressed: () async {
                            final tel = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(tel)) {
                              await launchUrl(tel);
                            }
                          },
                        ),
                      SahelButton.soft(
                        icon: Icons.chat,
                        label: 'محادثة',
                        width: 120,
                        onPressed: () => context.go('/inbox'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: SahelRadii.lgRadius,
              side: const BorderSide(color: SahelColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الفاتورة',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _amountRow('القيمة الأساسية',
                      str(booking['formatted_subtotal'] ?? booking['subtotal'])),
                  const SizedBox(height: 8),
                  if (toDoubleOrNull(booking['discount']) != null &&
                      toDouble(booking['discount']) > 0) ...[
                    _amountRow(
                        'الخصم',
                        '−${str(booking['formatted_discount'] ?? booking['discount'])}',
                        color: SahelColors.success),
                    const SizedBox(height: 8),
                  ],
                  if (toDoubleOrNull(booking['platform_fee']) != null) ...[
                    _amountRow('رسوم المنصة',
                        str(booking['formatted_platform_fee'] ?? booking['platform_fee'])),
                    const SizedBox(height: 8),
                  ],
                  if (toDoubleOrNull(booking['tax'] ?? booking['vat']) !=
                      null) ...[
                    _amountRow('الضريبة',
                        str(booking['formatted_tax'] ?? booking['tax'] ?? booking['vat'])),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الإجمالي',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(
                        str(booking['formatted_total'] ?? booking['total'],
                            '—'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: SahelColors.primary700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: SahelColors.primary600, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'طريقة الدفع: ${str(booking['payment_method'], '—')}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: SahelColors.text),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          isPaid ? 'مدفوع ✓' : 'قيد الدفع',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: isPaid
                                ? SahelColors.success
                                : SahelColors.amber,
                          ),
                        ),
                        backgroundColor: isPaid
                            ? SahelColors.successSoft
                            : SahelColors.amberSoft,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!isPaid && status == BookingStatus.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SahelButton.gradient(
                icon: Icons.payment,
                label: 'الدفع الآن',
                onPressed: () => _pay(context, ref),
              ),
            ),
          if (canCancel)
            SahelButton.danger(
              label: 'إلغاء الحجز',
              onPressed: () => _cancel(context, ref),
            )
          else
            const Text(
              'لا يمكن إلغاء هذا الحجز',
              style: TextStyle(
                  color: SahelColors.textMuted,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          if (status == BookingStatus.completed) ...[
            const SizedBox(height: 12),
            SahelButton.soft(
              label: 'تقييم الخدمة',
              onPressed: () =>
                  context.push('/bookings/$bookingId/review'),
            ),
            const SizedBox(height: 12),
            SahelButton.soft(
              label: 'إعادة الحجز',
              onPressed: () => _rebook(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: SahelColors.surface3,
          borderRadius: SahelRadii.smRadius,
          border: Border.all(color: SahelColors.border),
        ),
        child:
            const Icon(Icons.image, color: SahelColors.textMuted, size: 32),
      );

  Widget _amountRow(String label, String value, {Color? color}) => Row(
        children: [
          Text(label, style: muted),
          const Spacer(),
          Text(value.isEmpty ? '—' : value,
              style: amountStyle.copyWith(color: color)),
        ],
      );

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reason = await _askReason(context);
    if (reason == null || !context.mounted) return;
    try {
      await ref
          .read(customerRepositoryProvider)
          .cancelBooking(bookingId, reason);
      ref.invalidate(customerBookingProvider(bookingId));
      ref.invalidate(customerBookingsProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إلغاء الحجز')));
      }
    }
  }

  Future<void> _rebook(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(customerRepositoryProvider).rebook(bookingId);
      ref.invalidate(customerBookingsProvider);
      if (context.mounted) context.go('/bookings');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إعادة الحجز')));
      }
    }
  }

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(customerRepositoryProvider)
          .payBooking(bookingId, 'wallet');
      ref.invalidate(customerBookingProvider(bookingId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذر الدفع')));
      }
    }
  }

  Future<String?> _askReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب الإلغاء'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'اذكر سبب الإلغاء…'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تراجع')),
          TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, controller.text.trim()),
              child: const Text('تأكيد الإلغاء')),
        ],
      ),
    );
  }
}
