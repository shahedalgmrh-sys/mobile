import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class KycStatusScreen extends ConsumerStatefulWidget {
  const KycStatusScreen({super.key});

  @override
  ConsumerState<KycStatusScreen> createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends ConsumerState<KycStatusScreen> {
  static String _label(String status) => switch (status) {
    'verified' || 'approved' => 'موثّق',
    'pending' => 'قيد المراجعة',
    'rejected' => 'مرفوض',
    _ => 'غير مكتمل',
  };

  bool _uploading = false;

  Future<void> _upload() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(providerRepositoryProvider)
          .submitVerification(filePaths: [for (final f in files) f.path]);
      ref.invalidate(verificationStatusProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع الوثائق — قيد المراجعة')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر رفع الوثائق — حاول لاحقاً')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kyc = ref.watch(verificationStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهوية (KYC)')),
      body: SafeArea(
        child: kyc.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              ShimmerCard(height: 110),
              SizedBox(height: 20),
              ShimmerCard(height: 200),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(verificationStatusProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (k) {
            // `/provider/verification-status` responds with
            // `{is_verified, verification_status, latest_request}` where the
            // request carries `status`, `notes`, and `documents[]`.
            final latest = asMap(k['latest_request']);
            final verified =
                toBool(k['is_verified']) ||
                str(k['verification_status']) == 'verified' ||
                str(k['verification_status']) == 'approved' ||
                str(latest['status']) == 'approved';
            final rawStatus = verified
                ? 'verified'
                : str(k['verification_status'] ?? latest['status']);
            final status = rawStatus == 'approved' ? 'verified' : rawStatus;
            final notes = str(
              latest['notes'] ?? k['notes'] ?? k['rejection_reason'],
            );
            final docs = <Map<String, dynamic>>[];
            for (final d in asList(latest['documents'] ?? k['documents'])) {
              if (d is Map) {
                docs.add(asMap(d));
              } else {
                final path = str(d);
                if (path.isNotEmpty) {
                  docs.add({
                    'name': path.split('/').last,
                    'path': path,
                    'uploaded': true,
                  });
                }
              }
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: SahelColors.primary50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SahelColors.primary100),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: SahelColors.primary100,
                        child: Icon(
                          Icons.verified_user,
                          color: SahelColors.primary700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الحالة الحالية',
                              style: TextStyle(
                                color: SahelColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusPill.verifiedTeal(text: _label(status)),
                            const SizedBox(height: 6),
                            Text(
                              notes.isNotEmpty
                                  ? notes
                                  : status == 'verified'
                                  ? 'حسابك موثّق — يمكنك استقبال الحجوزات.'
                                  : 'سيتم مراجعة وثائقك خلال 24-48 ساعة عمل.',
                              style: const TextStyle(
                                color: SahelColors.primary700,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'الوثائق',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (docs.isEmpty)
                  Text(
                    status == 'pending'
                        ? 'الوثائق المرفوعة أثناء التسجيل قيد المراجعة الإدارية.'
                        : status == 'verified'
                        ? 'تم اعتماد حسابك، ولا حاجة لعرض الوثائق هنا.'
                        : 'لا توجد وثائق مسجلة',
                    style: const TextStyle(color: SahelColors.muted),
                  )
                else
                  for (final d in docs) _doc(d),
                const SizedBox(height: 28),
                if (status != 'verified' && status != 'pending')
                  _uploading
                      ? const Center(child: CircularProgressIndicator())
                      : SahelButton(
                          label: 'رفع الوثائق',
                          variant: SahelButtonVariant.gradient,
                          onPressed: _upload,
                        ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _doc(Map<String, dynamic> d) {
    final uploaded =
        toBool(d['uploaded'] ?? (d['url'] != null)) ||
        str(d['status']) == 'uploaded';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: uploaded
                  ? SahelColors.green600.withValues(alpha: 0.12)
                  : SahelColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              uploaded ? Icons.check_circle : Icons.upload_file_outlined,
              color: uploaded ? SahelColors.green600 : SahelColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              str(d['name'] ?? d['type'] ?? d['label'], 'وثيقة'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            uploaded ? 'مرفوع' : 'مطلوب',
            style: TextStyle(
              color: uploaded ? SahelColors.green600 : SahelColors.red600,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
