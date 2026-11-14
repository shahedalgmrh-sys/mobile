import 'dart:math' show atan2, cos, sin, pi, sqrt;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/core/constants/payment_methods.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class _DayAvailability {
  const _DayAvailability({required this.slots, this.error});

  final List<Map<String, dynamic>> slots;
  final String? error;

  bool get isAvailable => slots.isNotEmpty;
}

class BookingWizardScreen extends ConsumerStatefulWidget {
  final String? serviceId;

  /// Full service payload passed from the details screen. This avoids
  /// depending on the public `/services` list, which only returns its first
  /// page and ignores filters.
  final Service? initialService;
  const BookingWizardScreen({super.key, this.serviceId, this.initialService});

  @override
  ConsumerState<BookingWizardScreen> createState() =>
      _BookingWizardScreenState();
}

class _BookingWizardScreenState extends ConsumerState<BookingWizardScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final _frequencies = const ['مرة واحدة', 'أسبوعياً', 'أسبوعين', 'شهرياً'];
  int _selectedFrequency = 0;
  String? _selectedPricingId;
  final _couponController = TextEditingController();
  Map<String, dynamic>? _appliedCoupon;

  String? _selectedAddressId;

  DateTime _selectedDay = DateTime.now();
  DateTime _calMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Map<String, dynamic>> _slots = const [];
  bool _loadingCalendarAvailability = false;
  String? _slotError;
  String? _selectedSlotTime;
  Map<String, _DayAvailability> _availability = const {};

  /// Cache key for a calendar day: `yyyy-MM-dd`.
  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  int _selectedPayment = 0;
  bool _submitting = false;

  Service? get _service {
    if (widget.initialService != null) return widget.initialService;
    final list = ref.read(
      servicesProvider((q: null, categoryId: null, sort: null))
          .select((v) => v.valueOrNull),
    );
    if (list == null || widget.serviceId == null) return null;
    for (final s in list) {
      if (s is Service &&
          (s.id == widget.serviceId || s.slug == widget.serviceId)) {
        return s;
      }
    }
    return null;
  }

  /// Selected pricing tier's effective price when one is picked, otherwise
  /// the service base price.
  double get _subtotal {
    final service = _service;
    if (service == null) return 0;
    if (_selectedPricingId != null) {
      for (final tier in service.pricing) {
        if (tier.id == _selectedPricingId) return tier.effectivePrice;
      }
    }
    return service.basePrice;
  }

  double _appliedDiscount = 0;
  double get _discount => _appliedCoupon == null ? 0 : _appliedDiscount;

  double get _platformFee => (_subtotal - _discount) * 0.10;
  double get _tax => (_subtotal - _discount + _platformFee) * 0.15;
  double get _total => _subtotal - _discount + _platformFee + _tax;

  String get _currency => (_service?.currencyCode ?? 'yer').toUpperCase();

  /// Real service id (numeric) — never the slug — as required by the API.
  String? get _serviceId => _service?.id ?? widget.serviceId;

  String get _selectedPaymentCode {
    final i = _selectedPayment.clamp(0, PaymentMethods.booking.length - 1);
    return PaymentMethods.booking[i].$1;
  }

  /// Free-text note only used when the service has no pricing tiers — the
  /// frequency chips then have no server-side meaning (kept informational).
  String? get _bookingNotes {
    final service = _service;
    if (service == null || service.pricing.isNotEmpty) return null;
    return 'التكرار: ${_frequencies[_selectedFrequency]}';
  }

  String _dateParam(DateTime d) => _dayKey(d);

  /// Friendly label for the selected slot (e.g. «10:00 ص»), falling back to
  /// the raw `H:i` value.
  String? get _selectedSlotLabel {
    final t = _selectedSlotTime;
    if (t == null) return null;
    for (final s in _slots) {
      if (str(s['time']) == t) return str(s['label_ar'] ?? s['label'], t);
    }
    return t;
  }

  /// Friendly label for the selected day («الأحد 12 أكتوبر 2026»).
  String _selectedDayLabel() {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const days = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
    final d = _selectedDay;
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  /// Surfaces the backend's Arabic validation/business messages instead of a
  /// generic failure string (mirrors `AuthProvider._failureMessage`).
  String _failureMessage(Object e, [String fallback = 'حدث خطأ غير متوقع.']) {
    if (e is ApiException) {
      final f = e.failure;
      if (f is ValidationFailure) {
        return f.errors.values.expand((l) => l).join('\n');
      }
      if (f is ServerFailure) return f.message;
      if (f is NetworkFailure) return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
      if (f is UnauthorizedFailure) return 'انتهت الجلسة. سجّل الدخول مجدداً.';
    }
    return fallback;
  }

  /// Loads per-day availability for the whole displayed month (from today
  /// onwards), in chunks so the local API is not flooded in one burst.
  Future<void> _loadCalendarAvailability() async {
    final id = _serviceId;
    if (id == null) {
      setState(() {
        _availability = const {};
        _slots = const [];
        _slotError = null;
      });
      return;
    }

    setState(() {
      _loadingCalendarAvailability = true;
      _slotError = null;
    });

    final repo = ref.read(customerRepositoryProvider);
    final today = DateTime.now();
    final monthStart = DateTime(_calMonth.year, _calMonth.month, 1);
    final monthEnd = DateTime(_calMonth.year, _calMonth.month + 1, 0);
    final firstDay = monthStart.isBefore(today) ? today : monthStart;
    final lastDay = monthEnd.isAfter(today.add(const Duration(days: 90)))
        ? today.add(const Duration(days: 90))
        : monthEnd;

    final days = <DateTime>[];
    for (
      var d = firstDay;
      !d.isAfter(lastDay);
      d = d.add(const Duration(days: 1))
    ) {
      days.add(d);
    }

    final loaded = <String, _DayAvailability>{};
    const chunkSize = 7;
    for (var i = 0; i < days.length; i += chunkSize) {
      final chunk = days.skip(i).take(chunkSize).toList();
      final results = await Future.wait([
        for (final d in chunk) _fetchDay(repo, id, d),
      ]);
      for (final entry in results) {
        loaded[entry.key] = entry.value;
      }
      if (mounted) {
        setState(() => _availability = {..._availability, ...loaded});
      }
    }

    if (!mounted) return;

    final fallbackKey = loaded.keys
        .where((k) => loaded[k]?.isAvailable == true)
        .firstOrNull;
    final selectedKey = _dayKey(_selectedDay);
    final nextKey = _availability[selectedKey]?.isAvailable == true
        ? selectedKey
        : (fallbackKey ?? selectedKey);

    setState(() {
      _loadingCalendarAvailability = false;
      _selectedDay = DateTime.tryParse(nextKey) ?? _selectedDay;
      _slots = _availability[nextKey]?.slots ?? const [];
      _slotError = _availability[nextKey]?.error;
      if (_selectedSlotTime != null &&
          !_slots.any((slot) => str(slot['time']) == _selectedSlotTime)) {
        _selectedSlotTime = null;
      }
    });
  }

  Future<MapEntry<String, _DayAvailability>> _fetchDay(
    CustomerRepository repo,
    String serviceId,
    DateTime day,
  ) async {
    try {
      final slots = await repo.availableSlots(
        serviceId: serviceId,
        date: _dayKey(day),
      );
      return MapEntry(_dayKey(day), _DayAvailability(slots: slots));
    } catch (e) {
      return MapEntry(
        _dayKey(day),
        _DayAvailability(
          slots: const [],
          error: _failureMessage(e, 'تعذر فحص التوفر في هذا اليوم.'),
        ),
      );
    }
  }

  void _selectDay(DateTime day) {
    final availability = _availability[_dayKey(day)];
    if (_loadingCalendarAvailability ||
        availability == null ||
        !availability.isAvailable) {
      return;
    }
    setState(() {
      _selectedDay = day;
      _slots = availability.slots;
      _slotError = availability.error;
      if (_selectedSlotTime != null &&
          !_slots.any((slot) => str(slot['time']) == _selectedSlotTime)) {
        _selectedSlotTime = null;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step == 1 && _selectedAddressId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('اختر عنواناً أولاً')));
      return;
    }
    if (_step == 2 && _selectedSlotTime == null) {
      // The spec: an available day opens the interactive clock directly.
      final slotsAsync = _slots;
      if (slotsAsync.isNotEmpty) {
        await _openTimeDial();
        if (_selectedSlotTime == null || !mounted) return;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('اختر موعداً أولاً')));
        return;
      }
    }
    if (_step < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
      if (_step == 2) _loadCalendarAvailability();
    }
  }

  void _pageMonth(int delta) {
    setState(() {
      _calMonth = DateTime(_calMonth.year, _calMonth.month + delta, 1);
    });
    _loadCalendarAvailability();
  }

  static String _monthLabel(DateTime d) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _prev() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step--);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    try {
      final res = await ref
          .read(customerRepositoryProvider)
          .validateCoupon(code, subtotal: _subtotal, serviceId: _serviceId);
      if (!toBool(res['valid'], true)) {
        setState(() {
          _appliedCoupon = null;
          _appliedDiscount = 0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                dataList(res['errors']).map((e) => str(e)).join(' ').isEmpty
                    ? 'كوبون غير صالح'
                    : dataList(res['errors']).map((e) => str(e)).join(' '),
              ),
            ),
          );
        }
        return;
      }
      setState(() {
        _appliedCoupon = asMap(res['coupon'] ?? res);
        _appliedDiscount = toDouble(res['discount']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم تطبيق الكوبون')));
      }
    } catch (_) {
      setState(() {
        _appliedCoupon = null;
        _appliedDiscount = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('كوبون غير صالح')));
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final serviceId = _serviceId;
      final selectedTime = _selectedSlotTime;
      if (serviceId == null || selectedTime == null) {
        throw const ApiException(
          ServerFailure(code: 0, message: 'اختر الموعد قبل متابعة الحجز.'),
        );
      }

      final refreshedSlots = await ref
          .read(customerRepositoryProvider)
          .availableSlots(serviceId: serviceId, date: _dateParam(_selectedDay));
      final slotStillAvailable = refreshedSlots.any(
        (slot) => str(slot['time']) == selectedTime,
      );
      if (!slotStillAvailable) {
        if (!mounted) return;
        setState(() {
          _availability = {
            ..._availability,
            _dayKey(_selectedDay): _DayAvailability(slots: refreshedSlots),
          };
          _slots = refreshedSlots;
          _selectedSlotTime = null;
          _step = 2;
        });
        _pageController.jumpToPage(2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('المزوّد خارج الخدمة في الموعد الذي اخترته الآن.'),
          ),
        );
        return;
      }

      final booking = await ref.read(customerRepositoryProvider).createBooking({
        'service_id': serviceId,
        'customer_address_id': _selectedAddressId,
        'booking_date': _dateParam(_selectedDay),
        'booking_time': selectedTime,
        if (_bookingNotes != null) 'notes': _bookingNotes,
        if (_selectedPricingId != null)
          'service_pricing_id': _selectedPricingId,
        if (_appliedCoupon != null)
          'coupon_code': _couponController.text.trim(),
      });
      if (!mounted) return;
      ref.invalidate(customerBookingsProvider);
      final newId = booking['id'] ?? booking['booking_id'];
      String? paymentWarning;
      // cash pays no API call (settled with the provider); wallet and
      // electronic methods attempt /pay — electronic may fail locally with a
      // gateway-not-configured message which we surface verbatim.
      if (newId != null && _selectedPaymentCode != 'cash') {
        try {
          await ref
              .read(customerRepositoryProvider)
              .payBooking(str(newId), _selectedPaymentCode);
        } catch (e) {
          paymentWarning = _failureMessage(
            e,
            'تم إنشاء الحجز لكن تعذر إتمام الدفع — يمكنك الدفع من تفاصيل الحجز.',
          );
        }
      }
      if (!mounted) return;
      if (newId != null) {
        context.pushReplacement('/bookings/$newId');
      } else {
        context.go('/bookings');
      }
      if (paymentWarning != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(paymentWarning)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _failureMessage(e, 'تعذر إنشاء الحجز. حاول مرة أخرى.'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حجز خدمة جديدة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
                              ? [
                                  BoxShadow(
                                    color: dotColor.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  color: SahelColors.onPrimary,
                                  size: 18,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? SahelColors.onPrimary
                                        : SahelColors.textMuted,
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
                            color: i < _step
                                ? SahelColors.primary600
                                : SahelColors.border,
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
                    child: SahelButton.soft(label: 'السابق', onPressed: _prev),
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
    final tiers = _service?.pricing ?? const <ServicePricing>[];
    final selectedTierId = _selectedPricingId;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: SahelRadii.lgRadius,
            side: BorderSide(color: SahelColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: SahelColors.primaryGradient,
                    borderRadius: SahelRadii.mdRadius,
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: SahelColors.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service?.titleAr ?? 'الخدمة المختارة',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _service?.durationMinutes != null
                            ? 'المدة المتوقعة: ${(_service!.durationMinutes! / 60).toStringAsFixed(1)} ساعة'
                            : '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SahelColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_subtotal.toStringAsFixed(0)} $_currency',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: SahelColors.primary700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (tiers.isNotEmpty) ...[
          const Text(
            'فئة السعر',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tier in tiers)
                ChoiceChip(
                  label: Text(
                    '${tier.name} · ${tier.effectivePrice.toStringAsFixed(0)} $_currency',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selectedTierId == tier.id
                          ? SahelColors.onPrimary
                          : SahelColors.text,
                    ),
                  ),
                  selected: selectedTierId == tier.id,
                  selectedColor: SahelColors.primary600,
                  backgroundColor: SahelColors.surface2,
                  shape: RoundedRectangleBorder(
                    borderRadius: SahelRadii.pillRadius,
                    side: BorderSide(
                      color: selectedTierId == tier.id
                          ? SahelColors.primary600
                          : SahelColors.border,
                    ),
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedPricingId = tier.id),
                ),
            ],
          ),
        ] else ...[
          const Text(
            'تكرار الخدمة',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_frequencies.length, (i) {
              final selected = _selectedFrequency == i;
              return ChoiceChip(
                label: Text(
                  _frequencies[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? SahelColors.onPrimary : SahelColors.text,
                  ),
                ),
                selected: selected,
                selectedColor: SahelColors.primary600,
                backgroundColor: SahelColors.surface2,
                shape: RoundedRectangleBorder(
                  borderRadius: SahelRadii.pillRadius,
                  side: BorderSide(
                    color: selected
                        ? SahelColors.primary600
                        : SahelColors.border,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedFrequency = i),
              );
            }),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'كوبون الخصم',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
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
                  onTap: _applyCoupon,
                ),
              ),
            ],
          ),
        ),
        if (_appliedCoupon != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: SahelColors.successSoft,
              borderRadius: SahelRadii.mdRadius,
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: SahelColors.success),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'تم تطبيق الخصم بنجاح (15%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SahelColors.success,
                    ),
                  ),
                ),
                Text(
                  '-${_discount.toStringAsFixed(0)} $_currency',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: SahelColors.success,
                  ),
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
        const Text(
          'اختر عنوان التوصيل',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        addresses.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'تعذر تحميل العناوين',
              style: TextStyle(color: SahelColors.textMuted),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'لا توجد عناوين محفوظة — أضف عنواناً جديداً',
                  style: TextStyle(color: SahelColors.textMuted),
                ),
              );
            }
            _selectedAddressId ??=
                items
                    .where((a) => toBool(a['is_default'] ?? a['is_primary']))
                    .map((a) => str(a['id']))
                    .firstOrNull ??
                (items.isNotEmpty ? str(items.first['id']) : null);
            return Column(
              children: [
                for (final a in items)
                  _addressTile(
                    id: str(a['id']),
                    label: str(a['label'] ?? a['title'], 'عنوان'),
                    body: str(
                      a['full_address'] ?? a['address'] ?? a['address_line'],
                    ),
                    isDefault: toBool(a['is_default'] ?? a['is_primary']),
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
            side: const BorderSide(
              color: SahelColors.primary600,
              style: BorderStyle.solid,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: SahelRadii.pillRadius,
            ),
          ),
          icon: const Icon(
            Icons.add_location_alt_outlined,
            color: SahelColors.primary600,
          ),
          label: const Text(
            'إضافة عنوان جديد',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: SahelColors.primary700,
            ),
          ),
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
            border: Border.all(
              color: selected ? SahelColors.primary600 : SahelColors.border,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? SahelColors.primary600
                      : SahelColors.surface,
                  borderRadius: SahelRadii.smRadius,
                ),
                child: Icon(
                  Icons.location_on,
                  color: selected
                      ? SahelColors.onPrimary
                      : SahelColors.primary600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: SahelColors.primary100,
                              borderRadius: SahelRadii.pillRadius,
                            ),
                            child: const Text(
                              'افتراضي',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: SahelColors.primary700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12,
                        color: SahelColors.textMuted,
                      ),
                    ),
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
        const Text(
          'اختر تاريخ الحجز',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (_loadingCalendarAvailability)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.lgRadius,
            border: Border.all(color: SahelColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: SahelColors.primary600,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'التقويم بالميلادي',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap:
                        _calMonth.isAfter(
                          DateTime(DateTime.now().year, DateTime.now().month),
                        )
                        ? () => _pageMonth(-1)
                        : null,
                    borderRadius: SahelRadii.smRadius,
                    child: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: SahelColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _monthLabel(_calMonth),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _pageMonth(1),
                    borderRadius: SahelRadii.smRadius,
                    child: const Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: SahelColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final name in const [
                    'أحد',
                    'اثنين',
                    'ثلاثاء',
                    'أربعاء',
                    'خميس',
                    'جمعة',
                    'سبت',
                  ])
                    Expanded(
                      child: Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: SahelColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _MonthCalendarGrid(
                month: _calMonth,
                availability: _availability,
                selectedKey: _dayKey(_selectedDay),
                loading: _loadingCalendarAvailability,
                onDayTap: _selectDay,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _AvailabilityLegend(
              color: SahelColors.success,
              label: 'أخضر غامق: متوفر',
            ),
            _AvailabilityLegend(
              color: SahelColors.danger,
              label: 'أحمر: غير متوفر',
            ),
          ],
        ),
        if (_selectedSlotLabel != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: SahelColors.primarySurface,
              borderRadius: SahelRadii.mdRadius,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available,
                  size: 18,
                  color: SahelColors.primary700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'الموعد المحدد: ${_selectedDayLabel()} · ${_selectedSlotLabel!}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SahelColors.primary700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'اختر الوقت',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (_loadingCalendarAvailability)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_slotError != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _slotError!,
              style: const TextStyle(color: SahelColors.textMuted),
            ),
          )
        else if (_slots.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'لا توجد أوقات متاحة في هذا اليوم — اختر يوماً آخر',
              style: TextStyle(color: SahelColors.textMuted),
            ),
          )
        else ...[
          InkWell(
            onTap: _openTimeDial,
            borderRadius: SahelRadii.lgRadius,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SahelColors.primarySurface,
                borderRadius: SahelRadii.lgRadius,
                border: Border.all(color: SahelColors.primary200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: const BoxDecoration(
                      color: SahelColors.primary600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: SahelColors.onPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSlotTime == null
                              ? 'اضغط لاختيار الوقت'
                              : 'الوقت المقدم: ${_selectedSlotLabel!}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'ساعة تفاعلية بتصميم التطبيق · فترات كل 30 دقيقة',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: SahelColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: SahelColors.primary600),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final slot in _slots)
                ChoiceChip(
                  label: Text(
                    str(slot['label_ar'] ?? slot['label'], str(slot['time'])),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  selected: _selectedSlotTime == str(slot['time']),
                  selectedColor: SahelColors.primary600,
                  labelStyle: TextStyle(
                    color: _selectedSlotTime == str(slot['time'])
                        ? SahelColors.onPrimary
                        : SahelColors.text,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedSlotTime = str(slot['time'])),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Opens the circular clock sheet; stores the picked `H:i` value.
  Future<void> _openTimeDial() async {
    final initial = _selectedSlotTime ?? '09:00';
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SahelColors.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _ClockTimeSheet(
        slots: _slots,
        initialTime: _slots.isNotEmpty
            ? str(_slots.first['time'], initial)
            : initial,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedSlotTime = picked);
  }

  Widget _buildStep4() {
    final wallet = ref.watch(customerWalletProvider).valueOrNull;
    final walletBalanceTxt = wallet == null
        ? 'الرصيد المتاح'
        : formatMoney(wallet['balance']);

    const payMethod = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: SahelColors.text,
    );
    const muted = TextStyle(fontSize: 12, color: SahelColors.textMuted);

    Widget invoiceRow(String t, String v, {Color? color, bool strike = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(t, style: muted),
            const Spacer(),
            Text(
              v,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
                decoration: strike ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const Text(
          'طريقة الدفع',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'cash',
              icon: Icon(Icons.payments_outlined, size: 18),
              label: Text(
                'كاش',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            ButtonSegment(
              value: 'pay',
              icon: Icon(Icons.credit_score_outlined, size: 18),
              label: Text(
                'دفع',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ],
          selected: {_selectedPaymentCode},
          onSelectionChanged: (s) {
            setState(() {
              _selectedPayment = s.first == 'cash' ? _cashIndex : _walletIndex;
            });
          },
        ),
        const SizedBox(height: 14),
        if (_selectedPaymentCode == 'cash') ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: SahelColors.warningSoft,
              borderRadius: SahelRadii.mdRadius,
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: SahelColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'كاش عند الاستلام — تدفع المبلغ للمزوّد نقداً عند تنفيذ الخدمة، وينعكس ذلك في تفاعل الحجز.',
                    style: TextStyle(fontSize: 12.5, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Wallet card — the only actively available electronic option.
          Material(
            color: SahelColors.primary600,
            borderRadius: SahelRadii.lgRadius,
            child: InkWell(
              borderRadius: SahelRadii.lgRadius,
              onTap: () => setState(() => _selectedPayment = _walletIndex),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: SahelColors.onPrimary.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: SahelRadii.smRadius,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: SahelColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'محفظة المنصة',
                              style: payMethod.copyWith(
                                color: SahelColors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'تُخصم فوراً بعد الدفع',
                              style: muted.copyWith(
                                color: SahelColors.onPrimary70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              walletBalanceTxt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: SahelColors.onPrimary,
                              ),
                            ),
                            Text(
                              str(wallet?['currency'], '').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: SahelColors.primary200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Other electronic methods exist on the server but are not
          // activated in the current environment — shown disabled.
          for (final (code, l, _) in PaymentMethods.topUp)
            if (code != 'wallet')
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: SahelColors.surface2,
                  borderRadius: SahelRadii.mdRadius,
                  border: Border.all(
                    color: SahelColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.credit_card_off_outlined,
                      size: 20,
                      color: SahelColors.textSoft,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l, style: payMethod)),
                    Text(
                      'غير مفعّلة حالياً',
                      style: muted.copyWith(
                        fontSize: 10,
                        color: SahelColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.lgRadius,
            border: Border.all(color: SahelColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص الفاتورة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              invoiceRow(
                'القيمة الأساسية',
                '${_subtotal.toStringAsFixed(0)} $_currency',
              ),
              if (_discount > 0)
                invoiceRow(
                  'خصم الكوبون',
                  '-${_discount.toStringAsFixed(0)} $_currency',
                  color: SahelColors.success,
                ),
              invoiceRow(
                'رسوم المنصة',
                '${_platformFee.toStringAsFixed(0)} $_currency',
              ),
              invoiceRow(
                'الضريبة 15%',
                '${_tax.toStringAsFixed(0)} $_currency',
              ),
              const Divider(height: 18),
              invoiceRow(
                'الإجمالي النهائي',
                '${_total.toStringAsFixed(0)} $_currency',
                color: SahelColors.primary700,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: SahelColors.primarySurface,
            borderRadius: SahelRadii.mdRadius,
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: SahelColors.primary700,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إعداد الدفع آمن ومشفّر. تصلك تفاصيل الحجز وفاتورته مباشرة بعد التأكيد.',
                  style: TextStyle(fontSize: 11.5, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _walletIndex = 0;
  static const _cashIndex = 1;
}

/// Circular clock time picker matching the app identity: 1–12 hour ring,
/// hour hand, AM/PM segments and minute chips. Returns the server format
/// `H:i` (24h) or null when cancelled.
class _ClockTimeSheet extends StatefulWidget {
  final List<Map<String, dynamic>> slots;
  final String initialTime; // 24h 'H:i'

  const _ClockTimeSheet({required this.slots, required this.initialTime});

  @override
  State<_ClockTimeSheet> createState() => _ClockTimeSheetState();
}

class _ClockTimeSheetState extends State<_ClockTimeSheet> {
  int _hour12 = 9;
  int _minute = 0;
  bool _am = true;
  static const _minutes = [0, 15, 30, 45];

  @override
  void initState() {
    super.initState();
    final parts = widget.initialTime.split(':');
    var h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
    var m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    if (!_minutes.contains(m)) {
      m = _minutes.reduce((a, b) => (a - m).abs() <= (b - m).abs() ? a : b);
    }
    _hour12 = h % 12 == 0 ? 12 : h % 12;
    _am = h < 12;
    _minute = m;
  }

  int get _hour24 =>
      _am ? (_hour12 == 12 ? 0 : _hour12) : (_hour12 == 12 ? 12 : _hour12 + 12);

  String get _serverTime =>
      '${_hour24.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  bool get _slotValid => widget.slots.any((s) => str(s['time']) == _serverTime);

  void _setFromTap(Offset center, Size size, Offset tap) {
    final dx = tap.dx - center.dx;
    final dy = tap.dy - center.dy;
    if (sqrt(dx * dx + dy * dy) < 26) return;
    final deg = (atan2(dy, dx) * 180 / pi + 90 + 360) % 360;
    final hour = (deg / 30).round() % 12;
    setState(() => _hour12 = hour == 0 ? 12 : hour);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.access_time,
                    size: 20,
                    color: SahelColors.primary600,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'اختيار وقت الحجز',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: SahelColors.textMuted),
                ),
              ],
            ),
            SizedBox(
              width: 262,
              height: 262,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _setFromTap(
                  const Offset(131, 131),
                  const Size(262, 262),
                  d.localPosition,
                ),
                child: CustomPaint(
                  painter: _ClockDialPainter(hour12: _hour12, minute: _minute),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('صباحاً (ص)')),
                ButtonSegment(value: false, label: Text('مساءً (م)')),
              ],
              selected: {_am},
              onSelectionChanged: (s) => setState(() => _am = s.first),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final m in _minutes)
                  FilterChip(
                    selected: _minute == m,
                    label: Text(
                      m.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _minute == m
                            ? SahelColors.onPrimary
                            : SahelColors.text,
                      ),
                    ),
                    selectedColor: SahelColors.primary600,
                    checkmarkColor: SahelColors.onPrimary,
                    onSelected: (_) => setState(() => _minute = m),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _slotValid
                    ? SahelColors.primarySurface
                    : SahelColors.dangerSoft,
                borderRadius: SahelRadii.mdRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    _slotValid ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: _slotValid
                        ? SahelColors.primary700
                        : SahelColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _slotValid
                          ? 'الوقت المقدم ${_serverLabel()} — متاح ✓'
                          : 'الوقت المقدم ${_serverLabel()} — خارج الخدمة، اختر وقتاً آخر',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _slotValid
                            ? SahelColors.primary700
                            : SahelColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _slotValid
                          ? () => Navigator.pop(context, _serverTime)
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('تأكيد اختيار الوقت'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _serverLabel() {
    final parts = _serverTime.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:${parts.length > 1 ? parts[1] : '00'} ${_am ? 'ص' : 'م'}';
  }
}

class _ClockDialPainter extends CustomPainter {
  final int hour12;
  final int minute;
  _ClockDialPainter({required this.hour12, required this.minute});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = SahelColors.onPrimary
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = SahelColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 5, Paint()..color = SahelColors.primary700);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 1; i <= 12; i++) {
      final ang = (i * 30 - 90) * pi / 180;
      final p = Offset(
        center.dx + (radius - 20) * cos(ang),
        center.dy + (radius - 20) * sin(ang),
      );
      tp.text = TextSpan(
        text: '$i',
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: i == hour12 ? FontWeight.w900 : FontWeight.w600,
          color: i == hour12 ? SahelColors.primary700 : SahelColors.textMuted,
        ),
      );
      tp.layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    final hourAngle = (hour12 * 30 + minute / 2 - 90) * pi / 180;
    canvas.drawLine(
      center,
      center +
          Offset(
            (radius - 38) * cos(hourAngle),
            (radius - 38) * sin(hourAngle),
          ),
      Paint()
        ..color = SahelColors.primary700
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    final minuteAngle = (minute * 6 - 90) * pi / 180;
    canvas.drawLine(
      center,
      center +
          Offset(
            (radius - 16) * cos(minuteAngle),
            (radius - 16) * sin(minuteAngle),
          ),
      Paint()
        ..color = SahelColors.amber500
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockDialPainter oldDelegate) =>
      oldDelegate.hour12 != hour12 || oldDelegate.minute != minute;
}

/// Month day grid with green/red availability bars. Unavailable days are
/// Month day grid with green/red availability bars. Unavailable days are
/// non-tappable per the wizard flow requirement.
class _MonthCalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, _DayAvailability> availability;
  final String selectedKey;
  final bool loading;
  final void Function(DateTime) onDayTap;

  const _MonthCalendarGrid({
    required this.month,
    required this.availability,
    required this.selectedKey,
    required this.loading,
    required this.onDayTap,
  });

  static String keyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leadingBlanks = first.weekday % 7; // Sunday-first grid
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++)
        const Expanded(child: SizedBox(height: 1)),
      for (var day = 1; day <= daysInMonth; day++)
        () {
          final d = DateTime(month.year, month.month, day);
          final key = keyOf(d);
          final dayAv = availability[key];
          final isAvailable = dayAv?.isAvailable ?? false;
          final isPast = d.isBefore(todayStart);
          final known = dayAv != null;
          final selectable = !isPast && known && isAvailable && !loading;
          final selected = key == selectedKey;

          final bg = selected
              ? SahelColors.primary600
              : isPast
              ? SahelColors.surface3
              : (!known || loading)
              ? SahelColors.surface2
              : (isAvailable ? SahelColors.primary50 : SahelColors.surface3);
          final fg = selected
              ? SahelColors.onPrimary
              : isPast
              ? SahelColors.textSoft
              : (!known)
              ? SahelColors.textSoft
              : (isAvailable
                    ? SahelColors.primary700
                    : SahelColors.danger.withValues(alpha: 0.7));
          final bar = selected
              ? SahelColors.onPrimary
              : (!known)
              ? SahelColors.border
              : (isAvailable ? SahelColors.success : SahelColors.danger);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Material(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                shape: selected
                    ? null
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: SahelColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                child: InkWell(
                  onTap: selectable ? () => onDayTap(d) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 16,
                          height: 4,
                          decoration: BoxDecoration(
                            color: bar,
                            borderRadius: SahelRadii.pillRadius,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }(),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      final end = (i + 7) <= cells.length ? i + 7 : cells.length;
      rows.add(
        Row(
          children: [
            for (var j = i; j < end; j++) cells[j],
            for (var j = end; j < i + 7; j++)
              const Expanded(child: SizedBox(height: 1)),
          ],
        ),
      );
    }

    return Column(children: rows);
  }
}

class _AvailabilityLegend extends StatelessWidget {
  const _AvailabilityLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: SahelRadii.pillRadius,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: SahelColors.textMuted,
          ),
        ),
      ],
    );
  }
}
