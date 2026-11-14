import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

import 'complaint_helpers.dart';

/// Read-only complaint details built from `GET /customer/complaints`.
///
/// The API has no customer-side show/reply/close endpoint (those exist only on
/// the web session routes), so this screen never offers a reply box.
class ComplaintDetailsScreen extends ConsumerWidget {
  const ComplaintDetailsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(customerComplaintsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الشكوى')),
      body: complaints.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [ShimmerCard(height: 160), SizedBox(height: 12)],
        ),
        error: (e, _) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(customerComplaintsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ),
        data: (items) {
          Map<String, dynamic>? complaint;
          for (final item in items) {
            if (str(item['id']) == id) {
              complaint = item;
              break;
            }
          }
          if (complaint == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off,
                        size: 44, color: SahelColors.textSoft),
                    const SizedBox(height: 12),
                    const Text(
                      'الشكوى غير موجودة ضمن آخر 15 شكوى يعيدها API.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SahelColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(customerComplaintsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث القائمة'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _ComplaintBody(c: complaint);
        },
      ),
    );
  }
}

class _ComplaintBody extends StatelessWidget {
  const _ComplaintBody({required this.c});

  final Map<String, dynamic> c;

  @override
  Widget build(BuildContext context) {
    final status = str(c['status'], 'open');
    final priority = str(c['priority'], 'medium');
    final number = str(c['complaint_number']);
    final subject = str(c['subject'], 'شكوى');
    final booking = asMap(c['booking']);
    final against = asMap(c['against']);
    final messages = complaintMessages(c);
    final date = complaintDate(c['created_at']);
    final resolved = complaintDate(c['resolved_at']);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            border: Border.all(color: SahelColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(subject,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: complaintStatusColor(status)
                          .withValues(alpha: 0.12),
                      borderRadius: SahelRadii.pillRadius,
                    ),
                    child: Text(
                      complaintStatusLabel(status),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: complaintStatusColor(status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(
                    icon: Icons.flag_outlined,
                    text: 'أولوية ${complaintPriorityLabel(priority)}',
                    color: complaintPriorityColor(priority),
                  ),
                  if (number.isNotEmpty)
                    _MetaChip(
                      icon: Icons.confirmation_number_outlined,
                      text: number,
                      color: SahelColors.textMuted,
                    ),
                  if (date.isNotEmpty)
                    _MetaChip(
                      icon: Icons.schedule,
                      text: date,
                      color: SahelColors.textMuted,
                    ),
                  if (resolved.isNotEmpty)
                    _MetaChip(
                      icon: Icons.check_circle_outline,
                      text: 'أُغلقت $resolved',
                      color: SahelColors.success,
                    ),
                ],
              ),
              if (str(booking['service']).isNotEmpty ||
                  str(booking['booking_number']).isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.cleaning_services_outlined,
                  label: 'الحجز',
                  value: [
                    if (str(booking['service']).isNotEmpty)
                      str(booking['service']),
                    if (str(booking['booking_number']).isNotEmpty)
                      str(booking['booking_number']),
                  ].join(' · '),
                ),
              ],
              if (str(against['name']).isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'ضد',
                  value: str(against['name']),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            border: Border.all(color: SahelColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('وصف المشكلة',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                str(c['description'], 'لا يوجد وصف'),
                style: const TextStyle(
                    fontSize: 13, height: 1.6, color: SahelColors.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('محادثة الشكوى',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (messages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: SahelColors.surface2,
              borderRadius: SahelRadii.mdRadius,
            ),
            child: const Text('لا توجد ردود من فريق الدعم بعد.',
                style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
          )
        else
          for (final m in messages) _MessageBubble(m: m),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: SahelColors.infoSoft,
            borderRadius: SahelRadii.mdRadius,
          ),
          child: const Text(
            'الرد على الشكوى وإغلاقها غير متاحين عبر API التطبيق — مساراهما ويب فقط. '
            'يمكنك متابعة الردود هنا أو التواصل مع الدعم.',
            style: TextStyle(
                fontSize: 11, height: 1.6, color: SahelColors.primary700),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: SahelColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(fontSize: 12, color: SahelColors.textMuted)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 12, color: SahelColors.text)),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.m});

  final Map<String, dynamic> m;

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = asMap(m['user']);
    final role = str(user['role']).toLowerCase();
    final isCustomer = role == 'customer';
    final author = isCustomer
        ? 'أنت'
        : str(user['name'], 'فريق الدعم');
    final attachments = asList(m['attachments'])
        .map((a) => a.toString())
        .where((a) => a.isNotEmpty)
        .toList();
    final date = complaintDate(m['created_at']);

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isCustomer ? SahelColors.primarySurface : SahelColors.surface,
          borderRadius: SahelRadii.mdRadius,
          border: Border.all(color: SahelColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: SahelColors.textMuted)),
            const SizedBox(height: 4),
            Text(str(m['message']),
                style: const TextStyle(fontSize: 13, height: 1.5)),
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final url in attachments)
                InkWell(
                  onTap: () => _open(url),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file,
                            size: 14, color: SahelColors.primary600),
                        SizedBox(width: 4),
                        Text('مرفق',
                            style: TextStyle(
                                fontSize: 11,
                                color: SahelColors.primary700,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
            if (date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(date,
                  style: const TextStyle(
                      fontSize: 9, color: SahelColors.textSoft)),
            ],
          ],
        ),
      ),
    );
  }
}
