import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Customer payments & invoices — mirrors the website `/payments` page
/// against `/api/customer/payments` (+ `/{id}` and `/{id}/invoice`).
class CustomerPaymentsScreen extends ConsumerWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(customerPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مدفوعاتي وفواتيري')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(customerPaymentsProvider),
        child: payments.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 90),
              SizedBox(height: 10),
              ShimmerCard(height: 90),
              SizedBox(height: 10),
              ShimmerCard(height: 90),
            ],
          ),
          error: (e, _) => ListView(children: [
            const SizedBox(height: 80),
            Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(customerPaymentsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ]),
          data: (items) {
            if (items.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(
                  child: Text('لا توجد مدفوعات بعد',
                      style: TextStyle(
                          color: SahelColors.muted,
                          fontWeight: FontWeight.w700)),
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PaymentTile(p: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  final Map<String, dynamic> p;
  const _PaymentTile({required this.p});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = str(p['status'] ?? p['payment_status'], 'pending');
    final isPaid = status == 'completed' || status == 'paid' || status == 'success';
    final color = isPaid ? SahelColors.success : SahelColors.amber500;
    final amount = str(p['formatted_amount'] ?? p['amount']);
    final method = str(p['payment_method'] ?? p['method'], '—');
    final number = str(p['payment_number'] ?? p['number'] ?? p['id']);
    final date = str(p['date_ar'] ?? p['formatted_created_at'] ?? p['created_at']);
    final booking = asMap(p['booking']);
    final serviceName = str(booking['service_name'] ?? booking['service']?['name']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: SahelRadii.smRadius,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.schedule,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName.isNotEmpty ? serviceName : 'دفعة #$number',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$method · $date',
                      style: const TextStyle(
                          fontSize: 11, color: SahelColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isPaid
                            ? SahelColors.success
                            : SahelColors.text),
                  ),
                  Text(status,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openInvoice(context, ref, str(p['id'])),
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('عرض الفاتورة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openInvoice(
      BuildContext context, WidgetRef ref, String paymentId) async {
    try {
      final data = await ref
          .read(customerRepositoryProvider)
          .invoice(paymentId);
      final invoiceUrl = strOrNull(data['invoice_url'] ??
          data['url'] ??
          data['pdf_url'] ??
          data['download_url']);
      if (invoiceUrl != null) {
        final uri = Uri.tryParse(invoiceUrl);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم جلب الفاتورة — لا يوجد رابط تحميل')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تعذر جلب الفاتورة'),
              backgroundColor: SahelColors.danger),
        );
      }
    }
  }
}
