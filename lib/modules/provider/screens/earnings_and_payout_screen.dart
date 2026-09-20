import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class EarningsAndPayoutScreen extends StatefulWidget {
  const EarningsAndPayoutScreen({super.key});

  @override
  State<EarningsAndPayoutScreen> createState() => _EarningsAndPayoutScreenState();
}

class _EarningsAndPayoutScreenState extends State<EarningsAndPayoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedBank;
  final _amountController = TextEditingController(text: '1000');
  final _banks = const ['البنك الإسلامي اليمني', 'البنك الدولي للتنمية', 'بنك الكريمي', 'بنك الراجحي'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const balance = 24850.0;

    final transactions = [
      (id: 'BK-20260015', title: 'تنظيف شقق - آمال أحمد', date: '19 سبتمبر 2026', amount: 1000, type: 'earning'),
      (id: 'BK-20260014', title: 'صيانة مكيفات - خالد محمد', date: '18 سبتمبر 2026', amount: 800, type: 'earning'),
      (id: 'WD-20260003', title: 'سحب إلى البنك الإسلامي', date: '17 سبتمبر 2026', amount: 3000, type: 'withdraw'),
      (id: 'BK-20260013', title: 'سباكة منزلية - سارة علي', date: '16 سبتمبر 2026', amount: 600, type: 'earning'),
      (id: 'BK-20260012', title: 'كهرباء عامة - عمر حسن', date: '15 سبتمبر 2026', amount: 450, type: 'earning'),
      (id: 'BK-20260011', title: 'دهان جدران - نورة فهد', date: '14 سبتمبر 2026', amount: 1200, type: 'earning'),
      (id: 'WD-20260002', title: 'سحب إلى بنك الكريمي', date: '10 سبتمبر 2026', amount: 5000, type: 'withdraw'),
    ];

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: SahelColors.warmGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الرصيد المتاح للسحب',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ر.س',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: SahelRadii.pillRadius),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_up, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('+18% عن الشهر الماضي', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: SahelColors.amber700,
              unselectedLabelColor: Colors.white70,
              indicator: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(text: 'أسبوع'),
                Tab(text: 'شهر'),
                Tab(text: 'سنة'),
              ],
            ),
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: const BorderSide(color: SahelColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ملخص الأرباح', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 160,
                      child: Placeholder(
                        color: SahelColors.amber.withOpacity(0.2),
                        fallbackWidth: 300,
                        fallbackHeight: 120,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'مخطط بياني: الأسبوع\nالأحد: 800 · الإثنين: 1,100 · الثلاثاء: 950\nالأربعاء: 1,400 · الخميس: 750 · الجمعة: 0 · السبت: 1,000',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: SahelColors.textMuted, fontWeight: FontWeight.w600, height: 1.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _statMini('إجمالي الأرباح', '6,000 ر.س', SahelColors.primary700),
                        ),
                        Expanded(
                          child: _statMini('المسحوبات', '5,000 ر.س', SahelColors.danger),
                        ),
                        Expanded(
                          child: _statMini('الصافي', '1,000 ر.س', SahelColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: const BorderSide(color: SahelColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('طلب سحب رصيد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: SahelColors.infoSoft, borderRadius: SahelRadii.mdRadius),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: SahelColors.primary700),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'الحد الأدنى للسحب: 1,000 ر.س · يستغرق التحويل 1-3 أيام عمل',
                              style: TextStyle(fontSize: 11, color: SahelColors.primary700, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('اختر البنك', style: TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    InputDecorator(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedBank,
                          hint: const Text('اختر بنك الاستلام'),
                          items: _banks
                              .map((b) => DropdownMenuItem<String>(value: b, child: Text(b, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedBank = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('المبلغ المطلوب سحبه', style: TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        suffixText: 'ر.س',
                        prefixIcon: const Icon(Icons.monetization_on, color: SahelColors.amber),
                        border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [1000, 2000, 5000, 10000]
                          .map((v) => InkWell(
                                onTap: () => setState(() => _amountController.text = v.toString()),
                                borderRadius: SahelRadii.pillRadius,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: SahelColors.surface2,
                                    borderRadius: SahelRadii.pillRadius,
                                    border: Border.all(color: SahelColors.border),
                                  ),
                                  child: Text('$v ر.س', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SahelColors.primary700)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    SahelButton.gradient(
                      label: 'طلب سحب إلى البنك',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Text('آخر العمليات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Spacer(),
                TextButton(onPressed: null, child: Text('عرض الكل', style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w700, fontSize: 12))),
              ],
            ),
            const SizedBox(height: 4),
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: const BorderSide(color: SahelColors.border)),
              child: Column(
                children: List.generate(transactions.length, (i) {
                  final t = transactions[i];
                  final isEarning = t.type == 'earning';
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isEarning ? SahelColors.successSoft : SahelColors.dangerSoft,
                            borderRadius: SahelRadii.smRadius,
                          ),
                          child: Icon(
                            isEarning ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isEarning ? SahelColors.success : SahelColors.danger,
                            size: 18,
                          ),
                        ),
                        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: Text('${t.id} · ${t.date}', style: const TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                        trailing: Text(
                          '${isEarning ? '+' : '−'}${t.amount} ر.س',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isEarning ? SahelColors.success : SahelColors.danger),
                        ),
                      ),
                      if (i < transactions.length - 1) const Divider(height: 1, indent: 70),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statMini(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: SahelColors.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color), textAlign: TextAlign.center),
      ],
    );
  }
}
