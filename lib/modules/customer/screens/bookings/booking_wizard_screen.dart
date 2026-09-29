import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class BookingWizardScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  const BookingWizardScreen({super.key, this.serviceId});

  @override
  ConsumerState<BookingWizardScreen> createState() =>
      _BookingWizardScreenState();
}

class _BookingWizardScreenState
    extends ConsumerState<BookingWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final _frequencies = const [
    'مرة واحدة',
    'أسبوعياً',
    'أسبوعين',
    'شهرياً'
  ];
  static const _frequencyKeys = [
    'once',
    'weekly',
    'biweekly',
    'monthly'
  ];
  int _selectedFrequency = 0;
  final _couponController = TextEditingController();
  Map<String, dynamic>? _appliedCoupon;

  String? _selectedAddressId;

  int _selectedDate = 0;
  final _dates =
      List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
  final _timeSlots = const ['09:00', '10:00', '12:00', '15:00', '18:00'];
  int _selectedSlot = -1;

  static const _paymentKeys = ['wallet', 'card', 'cash_on_delivery'];
  static const _paymentLabels = ['محفظة', 'بطاقة', 'عند الاستلام'];
  int _selectedPayment = 0;
  bool _submitting = false;

  Service? get _service {
    final list = ref
        .read(servicesProvider((q: null, categoryId: null, sort: null))
            .select((v) => v.valueOrNull));
    if (list == null || widget.serviceId == null) return null;
    for (final s in list) {
      if (s is Service &&
          (s.id == widget.serviceId || s.slug == widget.serviceId)) {
        return s;
      }
    }
    return null;
  }

  double get _subtotal => _service?.basePrice ?? 0;
  double _appliedDiscount = 0;
  double get _discount => _appliedCoupon == null ? 0 : _appliedDiscount;

  double get _platformFee => (_subtotal - _discount) * 0.10;
  double get _tax => (_subtotal - _discount + _platformFee) * 0.15;
  double get _total => _subtotal - _discount + _platformFee + _tax;

  String get _currency => (_service?.currencyCode ?? 'yer').toUpperCase();

  @override
  void dispose() {
    _pageController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 && _selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر عنواناً أولاً')));
      return;
    }
    if (_step == 2 && _selectedSlot < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر موعداً أولاً')));
      return;
    }
    if (_step < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step--);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    try {
      final res = await ref
          .read(customerRepositoryProvider)
          .validateCoupon(code,
              subtotal: _subtotal,
              serviceId: widget.serviceId);
      if (!toBool(res['valid'], true)) {
        setState(() {
          _appliedCoupon = null;
          _appliedDiscount = 0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(dataList(res['errors'])
                      .map((e) => str(e))
                      .join(' ')
                      .isEmpty
                  ? 'كوبون غير صالح'
                  : dataList(res['errors'])
                      .map((e) => str(e))
                      .join(' '))));
        }
        return;
      }
      setState(() {
        _appliedCoupon = asMap(res['coupon'] ?? res);
        _appliedDiscount = toDouble(res['discount']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تطبيق الكوبون')));
      }
    } catch (_) {
      setState(() {
        _appliedCoupon = null;
        _appliedDiscount = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('كوبون غير صالح')));
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final d = _dates[_selectedDate];
      final booking = await ref
          .read(customerRepositoryProvider)
          .createBooking({
        'service_id': widget.serviceId ??
            widget.serviceId,
        'customer_address_id': _selectedAddressId,
        'booking_date':
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        'booking_time': _timeSlots[_selectedSlot],
        'notes': 'التكرار: ${_frequencies[_selectedFrequency]} · الدفع: ${_paymentLabels[_selectedPayment]}',
        if (_appliedCoupon != null)
          'coupon_code': _couponController.text.trim(),
      });
      if (!mounted) return;
      ref.invalidate(customerBookingsProvider);
      final newId = booking['id'] ?? booking['booking_id'];
      if (newId != null) {
        context.pushReplacement('/bookings/$newId');
      } else {
        context.go('/bookings');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إنشاء الحجز')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز خدمة جديدة', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isDone = i < _step;
                final isCurrent = i == _step;
                Color dotColor;
                if (isDone) {
                  dotColor = SahelColors.primary600;
                } else if (isCurrent) {
                  dotColor = SahelColors.amber;
                } else {
                  dotColor = SahelColors.border;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                          boxShadow: isCurrent
                              ? [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : SahelColors.textMuted,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      if (i < 3)
                        Container(
                          width: 32,
                          height: 3,
                          decoration: BoxDecoration(
                            color: i < _step ? SahelColors.primary600 : SahelColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: SahelButton.soft(
                      label: 'السابق',
                      onPressed: _prev,
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _submitting
                      ? const Center(child: CircularProgressIndicator())
                      : SahelButton.gradient(
                          label: _step == 3
                              ? 'تأكيد الحجز - ${_total.toStringAsFixed(0)} $_currency'
                              : 'التالي',
                          onPressed: _step == 3 ? _submit : _next,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SahelRadii.lgRadius,
            side: const BorderSide(color: SahelColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: SahelColors.primaryGradient,
                    borderRadius: SahelRadii.mdRadius,
                  ),
                  child: const Icon(Icons.cleaning_services, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_service?.titleAr ?? 'الخدمة المختارة',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        _service?.durationMinutes != null
                            ? 'المدة المتوقعة: ${(_service!.durationMinutes! / 60).toStringAsFixed(1)} ساعة'
                            : '',
                        style: const TextStyle(
                            fontSize: 12, color: SahelColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${_subtotal.toStringAsFixed(0)} $_currency',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: SahelColors.primary700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('تكرار الخدمة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_frequencies.length, (i) {
            final selected = _selectedFrequency == i;
            return ChoiceChip(
              label: Text(_frequencies[i], style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : SahelColors.text)),
              selected: selected,
              selectedColor: SahelColors.primary600,
              backgroundColor: SahelColors.surface2,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius, side: BorderSide(color: selected ? SahelColors.primary600 : SahelColors.border)),
              onSelected: (_) => setState(() => _selectedFrequency = i),
            );
          }),
        ),
        const SizedBox(height: 24),
        const Text('كوبون الخصم', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: SahelColors.surface2,
            borderRadius: SahelRadii.pillRadius,
            border: Border.all(color: SahelColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل كود الخصم...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: SahelButton.soft(
                    label: 'تطبيق',
                    height: 42,
                    width: 90,
                    onTap: _applyCoupon),
              ),
            ],
          ),
        ),
        if (_appliedCoupon != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: SahelColors.successSoft, borderRadius: SahelRadii.mdRadius),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: SahelColors.success),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'تم تطبيق الخصم بنجاح (15%)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SahelColors.success),
                  ),
                ),
                Text(
                  '-${_discount.toStringAsFixed(0)} $_currency',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: SahelColors.success),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    final addresses = ref.watch(customerAddressesProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const Text('اختر عنوان التوصيل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        addresses.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('تعذر تحميل العناوين',
                style: TextStyle(color: SahelColors.textMuted)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'لا توجد عناوين محفوظة — أضف عنواناً جديداً',
                    style: TextStyle(color: SahelColors.textMuted)),
              );
            }
            _selectedAddressId ??= items
                .where((a) => toBool(a['is_default'] ?? a['is_primary']))
                .map((a) => str(a['id']))
                .firstOrNull ??
                str(items.first['id']);
            return Column(
              children: [
                for (final a in items)
                  _addressTile(
                    id: str(a['id']),
                    label: str(a['label'] ?? a['title'], 'عنوان'),
                    body: str(a['full_address'] ??
                        a['address'] ??
                        a['address_line']),
                    isDefault:
                        toBool(a['is_default'] ?? a['is_primary']),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/addresses'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: SahelColors.primary600, style: BorderStyle.solid),
            shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
          ),
          icon: const Icon(Icons.add_location_alt_outlined, color: SahelColors.primary600),
          label: const Text('إضافة عنوان جديد', style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.primary700)),
        ),
      ],
    );
  }

  Widget _addressTile({
    required String id,
    required String label,
    required String body,
    required bool isDefault,
  }) {
    final selected = _selectedAddressId == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedAddressId = id),
        borderRadius: SahelRadii.mdRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: SahelRadii.mdRadius,
            color: selected ? SahelColors.primary50 : SahelColors.surface2,
            border: Border.all(color: selected ? SahelColors.primary600 : SahelColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? SahelColors.primary600 : SahelColors.surface,
                  borderRadius: SahelRadii.smRadius,
                ),
                child: Icon(Icons.location_on, color: selected ? Colors.white : SahelColors.primary600, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 8),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: SahelColors.primary100, borderRadius: SahelRadii.pillRadius),
                            child: const Text('افتراضي', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: SahelColors.primary700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(body, style: const TextStyle(fontSize: 12, color: SahelColors.textMuted)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? SahelColors.primary600 : SahelColors.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const Text('اختر تاريخ الحجز', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final d = _dates[i];
              final selected = _selectedDate == i;
              final dayNames = ['أحد', 'اثن', 'ثلا', 'أربع', 'خمي', 'جمع', 'سبت'];
              return InkWell(
                onTap: () => setState(() => _selectedDate = i),
                borderRadius: SahelRadii.mdRadius,
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: selected ? SahelColors.primary600 : SahelColors.surface2,
                    borderRadius: SahelRadii.mdRadius,
                    border: Border.all(color: selected ? SahelColors.primary600 : SahelColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(dayNames[d.weekday % 7], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : SahelColors.textMuted)),
                      const SizedBox(height: 4),
                      Text('${d.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: selected ? Colors.white : SahelColors.text)),
                      Text('${d.month}', style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : SahelColors.textMuted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text('اختر الوقت', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_timeSlots.length, (i) {
            final selected = _selectedSlot == i;
            return InkWell(
              onTap: () => setState(() => _selectedSlot = i),
              borderRadius: SahelRadii.mdRadius,
              child: Container(
                  width: 92,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? SahelColors.primary600 : SahelColors.surface2,
                    borderRadius: SahelRadii.mdRadius,
                    border: Border.all(color: selected ? SahelColors.primary600 : SahelColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(_timeSlots[i], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: selected ? Colors.white : SahelColors.text)),
                      const SizedBox(height: 2),
                      Text(
                        'متاح',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? Colors.white70 : SahelColors.success),
                      ),
                    ],
                  ),
                ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    final wallet = ref.watch(customerWalletProvider).valueOrNull;
    final walletBalance = wallet == null
        ? 'الرصيد المتاح'
        : 'الرصيد المتاح: ${str(wallet['formatted_balance'] ?? wallet['balance'])}';
    final methods = [
      (icon: Icons.account_balance_wallet, name: 'المحفظة الرقمية', desc: walletBalance),
      (icon: Icons.credit_card, name: 'بطاقة بنكية', desc: 'مدى / Visa / Mastercard'),
      (icon: Icons.monetization_on, name: 'الدفع عند الاستلام', desc: 'عند إكمال الخدمة'),
    ];
    const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SahelColors.text);
    const muted = TextStyle(fontSize: 12, color: SahelColors.textMuted);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const Text('طريقة الدفع', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...List.generate(methods.length, (i) {
          final m = methods[i];
          final selected = _selectedPayment == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedPayment = i),
              borderRadius: SahelRadii.mdRadius,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: SahelRadii.mdRadius,
                  color: selected ? SahelColors.primary50 : SahelColors.surface2,
                  border: Border.all(color: selected ? SahelColors.primary600 : SahelColors.border),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected ? SahelColors.primary600 : SahelColors.surface,
                        borderRadius: SahelRadii.smRadius,
                      ),
                      child: Icon(m.icon, color: selected ? Colors.white : SahelColors.primary600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: label),
                          const SizedBox(height: 2),
                          Text(m.desc, style: muted),
                        ],
                      ),
                    ),
                    Icon(
                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? SahelColors.primary600 : SahelColors.textSoft,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: const BorderSide(color: SahelColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ملخص الفاتورة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...[
                  ('القيمة الأساسية', '${_subtotal.toStringAsFixed(0)} $_currency'),
                  ('الخصم', '-${_discount.toStringAsFixed(0)} $_currency'),
                  ('رسوم المنصة', '${_platformFee.toStringAsFixed(0)} $_currency'),
                  ('الضريبة 15%', '${_tax.toStringAsFixed(0)} $_currency'),
                ].map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(r.$1, style: muted),
                          const Spacer(),
                          Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                Row(
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('${_total.toStringAsFixed(0)} $_currency', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SahelColors.primary700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
