import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';

enum NotificationType { booking, payment, chat, promo }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabs = ['الكل', 'الحجوزات', 'المدفوعات', 'المحادثات', 'العروض'];
    const types = [
      NotificationType.booking,
      NotificationType.payment,
      NotificationType.chat,
      NotificationType.promo,
      NotificationType.booking,
      NotificationType.payment,
      NotificationType.chat,
      NotificationType.promo,
      NotificationType.booking,
      NotificationType.payment,
      NotificationType.chat,
      NotificationType.promo,
      NotificationType.booking,
      NotificationType.payment,
      NotificationType.chat,
      NotificationType.promo,
      NotificationType.booking,
      NotificationType.payment,
      NotificationType.chat,
      NotificationType.promo,
    ];
    const titles = [
      'تم تأكيد حجزك #BK-20260001',
      'تم شحن المحفظة بمبلغ 1,000 ر.س',
      'رسالة جديدة من فني التنظيف',
      'عرض خاص: خصم 30% على خدمات المكيفات',
      'حجزك #BK-20260002 قيد التنفيذ',
      'تم استرداد 500 ر.س إلى محفظتك',
      'فني السباكة أرسل لك صوراً للإصلاح',
      'كوبون جديد صالح حتى نهاية الشهر',
      'أكمل حجزك #BK-20260003 وتقييم الخدمة',
      'عملية دفع ناجحة للحجز #BK-20260004',
      'تم إنشاء محادثة جديدة بخصوص حجزك',
      'خصم على حجزك القادم: 20% لجميع الخدمات',
      'المزوّد في الطريق إلى عنوانك',
      'تم خصم 1840 ر.س من محفظتك',
      'رسالة جديدة من خدمة العملاء',
      'عرض لمدة محدودة: شحن مجاني',
      'تم إعادة جدولة حجزك بنجاح',
      'تم إيداع أرباح الحجز في محفظتك',
      'لديك 3 رسائل غير مقروءة',
      'خصم 15% لعملائنا الأوفياء',
    ];
    const subtitles = [
      'منذ دقيقتين',
      'منذ 15 دقيقة',
      'منذ 30 دقيقة',
      'منذ ساعة',
      'منذ ساعتين',
      'منذ 3 ساعات',
      'منذ 4 ساعات',
      'أمس',
      'أمس',
      'أمس',
      'قبل يومين',
      'قبل يومين',
      'قبل 3 أيام',
      'قبل 3 أيام',
      'قبل 4 أيام',
      'قبل 5 أيام',
      'قبل أسبوع',
      'قبل أسبوع',
      'قبل أسبوعين',
      'قبل 3 أسابيع',
    ];
    final unread = List.generate(20, (i) => i < 7);

    final bookingColors = <NotificationType, (IconData, Color, Color)>{
      NotificationType.booking: (Icons.calendar_month, SahelColors.primary600, SahelColors.primary50),
      NotificationType.payment: (Icons.account_balance_wallet, SahelColors.amber, SahelColors.amberSoft),
      NotificationType.chat: (Icons.chat_bubble_outline, SahelColors.info, SahelColors.infoSoft),
      NotificationType.promo: (Icons.local_offer, SahelColors.violet, SahelColors.violetSoft),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mark_email_read_outlined, color: SahelColors.primary700),
            tooltip: 'تعليم الكل كمقروء',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: SahelColors.primary700,
          unselectedLabelColor: SahelColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          indicatorColor: SahelColors.primary700,
          indicatorWeight: 3,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (tabIdx) {
          final filtered = List.generate(20, (i) => i).where((i) {
            if (tabIdx == 0) return true;
            if (tabIdx == 1) return types[i] == NotificationType.booking;
            if (tabIdx == 2) return types[i] == NotificationType.payment;
            if (tabIdx == 3) return types[i] == NotificationType.chat;
            return types[i] == NotificationType.promo;
          }).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (ctx, listIdx) {
              final i = filtered[listIdx];
              final t = types[i];
              final meta = bookingColors[t]!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Material(
                  color: unread[i] ? SahelColors.primary50.withOpacity(0.4) : SahelColors.surface,
                  borderRadius: SahelRadii.mdRadius,
                  child: InkWell(
                    onTap: () => setState(() => unread[i] = false),
                    borderRadius: SahelRadii.mdRadius,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: SahelRadii.mdRadius,
                        border: Border.all(color: unread[i] ? SahelColors.primary200 : SahelColors.border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: meta.$3,
                            child: Icon(meta.$1, color: meta.$2, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        titles[i],
                                        style: TextStyle(
                                          fontWeight: unread[i] ? FontWeight.w800 : FontWeight.w600,
                                          fontSize: 13,
                                          color: SahelColors.text,
                                        ),
                                      ),
                                    ),
                                    if (unread[i]) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: SahelColors.primary600,
                                          borderRadius: SahelRadii.pillRadius,
                                        ),
                                        child: const Text(
                                          'جديد',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitles[i],
                                  style: const TextStyle(fontSize: 11, color: SahelColors.textMuted, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
