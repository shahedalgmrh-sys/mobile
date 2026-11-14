import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  /// Values must be real booking statuses stored by the API: it filters with
  /// `where('status', $status)`, so a UI-only value such as "upcoming" would
  /// always return an empty page.
  static const _tabs = [
    (label: 'الجميع', status: null),
    (label: 'قيد الانتظار', status: 'pending'),
    (label: 'مقبولة', status: 'accepted'),
    (label: 'جارية', status: 'in_progress'),
    (label: 'مكتملة', status: 'completed'),
    (label: 'ملغية', status: 'cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final tabs = [
      for (final t in _tabs) (label: t.label.t(lang), status: t.status),
    ];
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'حجوزاتي'.t(lang),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: SahelColors.primary700,
            unselectedLabelColor: SahelColors.textMuted,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            indicatorColor: SahelColors.primary700,
            indicatorWeight: 3,
            tabs: [for (final t in tabs) Tab(text: t.label)],
          ),
        ),
        body: TabBarView(
          children: [for (final t in _tabs) _BookingsTab(status: t.status)],
        ),
      ),
    );
  }
}

class _BookingsTab extends ConsumerStatefulWidget {
  final String? status;
  const _BookingsTab({this.status});

  @override
  ConsumerState<_BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends ConsumerState<_BookingsTab> {
  final ScrollController _scroll = ScrollController();
  final List<Map<String, dynamic>> _items = [];

  int _loadedPage = 0;
  int _lastPage = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _moreError = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(page: 1);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _load({required int page}) async {
    final append = page > 1;
    setState(() {
      if (append) {
        _loadingMore = true;
        _moreError = false;
      } else {
        _loading = true;
        _error = null;
      }
    });
    try {
      final envelope = await ref
          .read(customerRepositoryProvider)
          .bookingsPage(status: widget.status, page: page == 1 ? null : page);
      final items = dataList(envelope);
      final meta = asMap(envelope['meta']);
      final current = toInt(meta['current_page'], page);
      final last = toInt(meta['last_page'], current);
      final total = toInt(meta['total'], _items.length + items.length);
      if (!mounted) return;
      setState(() {
        if (!append) _items.clear();
        _items.addAll(items);
        _loadedPage = current;
        _lastPage = last;
        _total = total;
        _loading = false;
        _loadingMore = false;
        _moreError = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (append) {
          _moreError = true;
        } else {
          _error = 'تعذر تحميل الحجوزات';
        }
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _loadedPage >= _lastPage) return;
    await _load(page: _loadedPage + 1);
  }

  Future<void> _refresh() async {
    _loadedPage = 0;
    _lastPage = 1;
    _total = 0;
    await _load(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ShimmerCard(height: 84),
        ),
      );
    }
    if (_error != null) {
      return _ErrorState(onRetry: _refresh);
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [SizedBox(height: 120), _EmptyState()],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + 1,
        itemBuilder: (ctx, i) {
          if (i == _items.length) return _footer();
          return _BookingCard(booking: _items[i]);
        },
      ),
    );
  }

  Widget _footer() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_moreError) {
      return Center(
        child: TextButton.icon(
          onPressed: _loadMore,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('تعذر تحميل المزيد — إعادة المحاولة'),
        ),
      );
    }
    if (_loadedPage < _lastPage) {
      return Center(
        child: TextButton(
          onPressed: _loadMore,
          child: const Text('تحميل المزيد'),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          _total > 0
              ? 'تم عرض جميع الحجوزات ($_total)'
              : 'تم عرض جميع الحجوزات',
          style: const TextStyle(
            fontSize: 11,
            color: SahelColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final service = asMap(booking['service']);
    final number = str(booking['booking_number'] ?? booking['id']);
    final rawDate = booking['booking_date'] ?? booking['scheduled_at'];
    final formattedDate = formatDate(rawDate);
    final date = formattedDate.isNotEmpty ? formattedDate : str(rawDate);
    final price = booking['formatted_total'] != null
        ? str(booking['formatted_total'])
        : (booking['display_price'] != null
            ? str(booking['display_price'])
            : formatMoney(booking['total']));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        elevation: 0,
        child: InkWell(
          onTap: () => context.push('/bookings/${booking['id']}'),
          borderRadius: SahelRadii.mdRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: SahelRadii.mdRadius,
              border: Border.all(color: SahelColors.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: SahelColors.primaryGradient,
                    borderRadius: SahelRadii.smRadius,
                  ),
                  child: const Icon(
                    Icons.home_repair_service,
                    color: SahelColors.onPrimary,
                    size: 24,
                  ),
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
                              str(service['name'], 'خدمة'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          BookingStatusPill(
                            status: BookingStatusX.fromJson(
                              str(booking['status']),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (number.isNotEmpty) 'BK-$number',
                          if (date.isNotEmpty) date,
                          if (price.isNotEmpty) price,
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: SahelColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: SahelColors.primary600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: SahelColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'لا توجد حجوزات هنا بعد',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: SahelColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: SahelColors.textMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل الحجوزات',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: SahelColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
