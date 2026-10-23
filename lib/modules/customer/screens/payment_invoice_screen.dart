import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Standalone simplified-tax-invoice screen mirroring the Stitch reference
/// `_5` («فاتورة ضريبية مبسطة») against
/// `GET /api/customer/payments/{id}/invoice` — which returns the invoice
/// number, the payment, its booking and the issuance timestamp as JSON
/// (no PDF link, so the invoice is rendered natively).
class PaymentInvoiceScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentInvoiceScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(paymentInvoiceProvider(paymentId));

    return Scaffold(
      appBar: AppBar(title: const Text('فاتورة ضريبية مبسطة')),
      body: invoice.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ShimmerCard(height: 120),
            SizedBox(height: 12),
            ShimmerCard(height: 200),
            SizedBox(height: 12),
            ShimmerCard(height: 160),
          ],
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 56, color: SahelColors.textMuted),
              const SizedBox(height: 12),
              const Text('تعذر جلب الفاتورة',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SahelColors.textMuted)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(paymentInvoiceProvider(paymentId)),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (data) => _InvoiceView(data: data),
      ),
    );
  }
}

class _InvoiceView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _InvoiceView({required this.data});

  String _money(dynamic value, String currency) {
    final n = toDoubleOrNull(value);
    if (n == null) return '—';
    return '${n.toStringAsFixed(2)} ${currency.isEmpty ? 'SAR' : currency}';
  }

  @override
  Widget build(BuildContext context) {
    final payment = asMap(data['payment']);
    final booking = asMap(data['booking']);
    final invoiceNumber = str(data['invoice_number']);
    final issuedAt = str(data['issued_at'] ?? payment['created_at']);
    final status = str(payment['payment_status'] ?? payment['status']);
    final currency = str(booking['currency']);
    final service = asMap(booking['service']);
    final refunds = asMapList(payment['refunds']);

    final isPaid = ['completed', 'paid', 'success']
        .contains(status.toLowerCase());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ------------------------------------------------ invoice header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: SahelColors.primaryGradient,
            borderRadius: SahelRadii.lgRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.receipt_long,
                  color: SahelColors.onPrimary, size: 28),
              const SizedBox(height: 10),
              Text(
                invoiceNumber.isEmpty ? 'فاتورة' : invoiceNumber,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: SahelColors.onPrimary,
                ),
              ),
              Text(
                'صادرة: $issuedAt',
                style: const TextStyle(
                  fontSize: 12,
                  color: SahelColors.onPrimary70,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SahelColors.onPrimary.withValues(alpha: 0.16),
                  borderRadius: SahelRadii.pillRadius,
                ),
                child: Text(
                  isPaid ? 'مدفوعة' : 'قيد الدفع',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: SahelColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // --------------------------------------------------- booking info
        if (booking.isNotEmpty) ...[
          _InvoiceCard(title: 'بيانات الحجز', rows: [
            _row('رقم الحجز', str(booking['booking_number'])),
            if (service.isNotEmpty) _row('الخدمة', str(service['name'])),
            _row('التاريخ',
                '${str(booking['booking_date'])} ${str(booking['booking_time'])}'),
            _row('حالة الحجز',
                str(booking['status_label'] ?? booking['status'])),
          ]),
          const SizedBox(height: 12),
        ],

        // ------------------------------------------------ payment details
        _InvoiceCard(title: 'بيانات الدفعة', rows: [
          _row('طريقة الدفع',
              str(payment['payment_method'] ?? payment['method'])),
          _row('رقم الدفعة', str(payment['payment_number'] ?? payment['id'])),
          if (str(payment['transaction_id']).isNotEmpty)
            _row('رقم العملية', str(payment['transaction_id'])),
        ]),
        const SizedBox(height: 12),

        // ----------------------------------------------------- breakdown
        _InvoiceCard(title: 'الإجماليات', rows: [
          _row('المبلغ', _money(payment['amount'], currency)),
          if (toDoubleOrNull(payment['fee']) != null)
            _row('الرسوم', _money(payment['fee'], currency)),
          if (toDoubleOrNull(payment['net_amount']) != null)
            _row('الصافي', _money(payment['net_amount'], currency)),
          if (toDoubleOrNull(booking['subtotal']) != null)
            _row('الإجمالي الفرعي',
                _money(booking['subtotal'], currency)),
          if (toDoubleOrNull(booking['discount']) != null &&
              toDoubleOrNull(booking['discount'])! > 0)
            _row('الخصم', '− ${_money(booking['discount'], currency)}'),
          if (toDoubleOrNull(booking['tax']) != null)
            _row('الضريبة', _money(booking['tax'], currency)),
          if (toDoubleOrNull(booking['total']) != null)
            _row('المجموع', _money(booking['total'], currency)),
        ]),
        const SizedBox(height: 12),

        // ------------------------------------------------------- refunds
        if (refunds.isNotEmpty) ...[
          _InvoiceCard(
            title: 'الاستردادات',
            rows: refunds
                .map((r) => _row(
                      str(r['refund_number']),
                      '${_money(r['amount'], currency)} — ${str(r['status'])}',
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        const Text(
          'هذه فاتورة إلكترونية صادرة من تطبيق ساحل',
          textAlign: TextAlign.center,
          style: SahelTextStyles.caption,
        ),
      ],
    );
  }

  MapEntry<String, String> _row(String label, String value) =>
      MapEntry(label, value);
}

class _InvoiceCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  const _InvoiceCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: SahelColors.primary700,
              )),
          const SizedBox(height: 8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.key,
                      style: const TextStyle(
                          fontSize: 12.5, color: SahelColors.textMuted)),
                  const Spacer(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(row.value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: SahelColors.text)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
