import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/repositories/provider_repository.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// "طلباتي" — provider-to-provider service requests (B2B).
/// Mirrors the web `/provider/requests` page against `/api/provider/requests`.
class ProviderServiceRequestsScreen extends ConsumerStatefulWidget {
  const ProviderServiceRequestsScreen({super.key});

  @override
  ConsumerState<ProviderServiceRequestsScreen> createState() =>
      _ProviderServiceRequestsScreenState();
}

class _ProviderServiceRequestsScreenState
    extends ConsumerState<ProviderServiceRequestsScreen> {
  String _type = 'incoming';

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(serviceRequestsProvider(_type));

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي (تعاون المزوّدين)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/p/service-requests/new'),
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'incoming', label: Text('الواردة')),
                ButtonSegment(value: 'outgoing', label: Text('الصادرة')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(serviceRequestsProvider(_type)),
              child: requests.when(
                loading: () => ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    ShimmerCard(height: 120),
                    SizedBox(height: 12),
                    ShimmerCard(height: 120),
                  ],
                ),
                error: (e, _) => ListView(children: [
                  const SizedBox(height: 80),
                  Center(
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.invalidate(serviceRequestsProvider(_type)),
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
                        child: Text('لا توجد طلبات في هذا القسم',
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
                    itemBuilder: (_, i) => _RequestCard(
                      r: items[i],
                      isOutgoing: _type == 'outgoing',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final Map<String, dynamic> r;
  final bool isOutgoing;
  const _RequestCard({required this.r, required this.isOutgoing});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'accepted':
        return SahelColors.success;
      case 'completed':
        return SahelColors.green600;
      case 'rejected':
      case 'cancelled':
        return SahelColors.danger;
      case 'in_progress':
        return SahelColors.info;
      default:
        return SahelColors.amber500;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = str(r['status'], 'pending');
    final service = asMap(r['service']);
    final requester = asMap(r['requester_provider'] ?? r['requesterProvider']);
    final target = asMap(r['target_provider'] ?? r['targetProvider']);
    final counterpart = isOutgoing
        ? str(target['business_name'] ?? target['user_name'], 'مزوّد')
        : str(requester['business_name'] ?? requester['user_name'], 'مزوّد');
    final total = str(r['formatted_total'] ?? r['total']);
    final address = str(asMap(r['area'])['name'] ??
        asMap(r['city'])['name'] ??
        r['address_line']);
    final date = [str(r['scheduled_date']), str(r['scheduled_time'])]
        .where((e) => e.isNotEmpty)
        .join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(str(service['name'] ?? service['title'], 'خدمة'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: SahelRadii.pillRadius,
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _statusColor(status))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('مع: $counterpart · $date${address.isEmpty ? '' : ' · $address'}',
              style: const TextStyle(fontSize: 12, color: SahelColors.textMuted)),
          if (total.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(total,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: SahelColors.primary700)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isOutgoing && status == 'pending') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _reject(ref, context, str(r['id'])),
                    child: const Text('رفض',
                        style: TextStyle(color: SahelColors.danger)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _act(
                        ref, context, repo(ref).acceptServiceRequest(str(r['id'])),
                        success: 'تم قبول الطلب ✓'),
                    child: const Text('قبول'),
                  ),
                ),
              ],
              if (!isOutgoing &&
                  (status == 'accepted' || status == 'in_progress'))
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _act(
                        ref, context,
                        repo(ref).completeServiceRequest(str(r['id'])),
                        success: 'تم إتمام الطلب ✓'),
                    child: const Text('إتمام الطلب'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ProviderRepository repo(WidgetRef ref) =>
      ref.read(providerRepositoryProvider);

  Future<void> _act(WidgetRef ref, BuildContext context,
      Future<Object?> call, {
      required String success}) async {
    try {
      await call;
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(success)));
      }
      ref.invalidate(serviceRequestsProvider('incoming'));
      ref.invalidate(serviceRequestsProvider('outgoing'));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(
              content: Text('تعذر تحديث الطلب'),
              backgroundColor: SahelColors.danger));
      }
    }
  }

  /// `POST /provider/requests/{id}/reject` stores no reason, so we do not
  /// pretend to collect one.
  Future<void> _reject(
      WidgetRef ref, BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رفض الطلب؟'),
        content: const Text('سيُرفض طلب التعاون ولن يتمكن الطرف الآخر من متابعته.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('رفض',
                  style: TextStyle(color: SahelColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _act(ref, context, repo(ref).rejectServiceRequest(id),
        success: 'تم رفض الطلب');
  }
}
