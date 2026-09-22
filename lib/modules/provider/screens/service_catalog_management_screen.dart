import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class ServiceCatalogManagementScreen extends StatefulWidget {
  const ServiceCatalogManagementScreen({super.key});

  @override
  State<ServiceCatalogManagementScreen> createState() => _ServiceCatalogManagementScreenState();
}

class _ServiceCatalogManagementScreenState extends State<ServiceCatalogManagementScreen> {
  final List<_Service> _services = [
    _Service(id: 1, name: 'تنظيف شقق كامل', category: 'خدمات تنظيف', price: 1000, durationMin: 180, active: true, icon: Icons.cleaning_services, color: SahelColors.primary600),
    _Service(id: 2, name: 'صيانة مكيفات سبليت', category: 'التكييف والتبريد', price: 800, durationMin: 90, active: true, icon: Icons.air, color: SahelColors.success),
    _Service(id: 3, name: 'إصلاح تسريبات السباكة', category: 'السباكة', price: 600, durationMin: 60, active: true, icon: Icons.plumbing, color: SahelColors.info),
    _Service(id: 4, name: 'كهرباء منزلية عامة', category: 'خدمات كهربائية', price: 450, durationMin: 45, active: false, icon: Icons.electrical_services, color: SahelColors.amber),
  ];

  @override
  Widget build(BuildContext context) {
    final activeCount = _services.where((s) => s.active).length;
    final pausedCount = _services.length - activeCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة كتالوج الخدمات', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditSheet(null),
        backgroundColor: SahelColors.primary600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة خدمة', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: SahelColors.nightGradient,
              borderRadius: SahelRadii.lgRadius,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryChip('إجمالي الخدمات', '${_services.length}', Icons.list),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryChip('نشطة', '$activeCount', Icons.check_circle, bgColor: SahelColors.success.withOpacity(0.2), fgColor: SahelColors.success),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryChip('متوقفة', '$pausedCount', Icons.pause_circle, bgColor: SahelColors.textSoft.withOpacity(0.2), fgColor: SahelColors.textSoft),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('قائمة الخدمات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...List.generate(_services.length, (i) {
            final s = _services[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: SahelColors.surface,
                borderRadius: SahelRadii.lgRadius,
                child: InkWell(
                  onTap: () => _showEditSheet(s),
                  borderRadius: SahelRadii.lgRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: SahelRadii.lgRadius,
                      border: Border.all(color: s.active ? SahelColors.primary200 : SahelColors.border),
                      color: s.active ? SahelColors.surface : SahelColors.surface2,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: s.active ? s.color.withOpacity(0.12) : SahelColors.surface3,
                                borderRadius: SahelRadii.mdRadius,
                              ),
                              child: Icon(s.icon, color: s.active ? s.color : SahelColors.textSoft, size: 26),
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
                                          s.name,
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: s.active ? SahelColors.text : SahelColors.textMuted),
                                        ),
                                      ),
                                      Switch(
                                        value: s.active,
                                        onChanged: (v) => setState(() => s.active = v),
                                        activeTrackColor: SahelColors.success.withOpacity(0.4),
                                        activeThumbColor: SahelColors.success,
                                        inactiveTrackColor: SahelColors.textSoft.withOpacity(0.3),
                                        inactiveThumbColor: SahelColors.textSoft,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s.category,
                                    style: const TextStyle(fontSize: 11, color: SahelColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.monetization_on, size: 15, color: SahelColors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.price} ر.س',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: SahelColors.primary700),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.timer, size: 15, color: SahelColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.durationMin} دقيقة',
                                    style: const TextStyle(fontSize: 12, color: SahelColors.text, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: s.active ? SahelColors.successSoft : SahelColors.surface3,
                                    borderRadius: SahelRadii.pillRadius,
                                  ),
                                  child: Text(
                                    s.active ? 'نشطة' : 'متوقفة',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: s.active ? SahelColors.success : SahelColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, IconData icon, {Color? bgColor, Color? fgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.1),
        borderRadius: SahelRadii.mdRadius,
      ),
      child: Column(
        children: [
          Icon(icon, color: fgColor ?? Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fgColor ?? Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: fgColor != null ? fgColor.withOpacity(0.8) : Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showEditSheet(_Service? s) {
    final isEdit = s != null;
    final nameCtrl = TextEditingController(text: s?.name ?? '');
    final priceCtrl = TextEditingController(text: s != null ? s.price.toString() : '');
    final durationCtrl = TextEditingController(text: s != null ? s.durationMin.toString() : '');
    String? category = s?.category;
    bool active = s?.active ?? true;
    final cats = const ['خدمات تنظيف', 'التكييف والتبريد', 'السباكة', 'خدمات كهربائية', 'النجارة', 'الدهانات'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: SahelColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(color: SahelColors.surface3, borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(isEdit ? 'تعديل الخدمة' : 'إضافة خدمة جديدة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                _field('اسم الخدمة', nameCtrl),
                const SizedBox(height: 12),
                const Text('التصنيف', style: TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InputDecorator(
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: category,
                      hint: const Text('اختر تصنيف'),
                      items: cats.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setSheetState(() => category = v),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('السعر (ر.س)', priceCtrl, type: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('المدة (دقيقة)', durationCtrl, type: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('الخدمة متاحة للحجز', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    Switch(
                      value: active,
                      onChanged: (v) => setSheetState(() => active = v),
                      activeTrackColor: SahelColors.success.withOpacity(0.4),
                      activeThumbColor: SahelColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (isEdit) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _services.remove(s));
                            Navigator.of(ctx).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: SahelColors.danger),
                            foregroundColor: SahelColors.danger,
                            shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
                          ),
                          child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: SahelButton.gradient(
                        label: isEdit ? 'حفظ التعديلات' : 'إضافة الخدمة',
                        onPressed: () {
                          final newS = _Service(
                            id: s?.id ?? DateTime.now().millisecondsSinceEpoch,
                            name: nameCtrl.text,
                            category: category ?? 'غير مصنف',
                            price: double.tryParse(priceCtrl.text) ?? 0,
                            durationMin: int.tryParse(durationCtrl.text) ?? 60,
                            active: active,
                            icon: Icons.miscellaneous_services,
                            color: SahelColors.primary600,
                          );
                          setState(() {
                            if (isEdit) {
                              final idx = _services.indexWhere((e) => e.id == s.id);
                              if (idx >= 0) _services[idx] = newS;
                            } else {
                              _services.add(newS);
                            }
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _Service {
  final int id;
  final IconData icon;
  final Color color;
  String name;
  String category;
  double price;
  int durationMin;
  bool active;

  _Service({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMin,
    required this.active,
    required this.icon,
    required this.color,
  });
}
