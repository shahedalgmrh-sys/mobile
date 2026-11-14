import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/modules/customer/screens/wallet/wallet_screen.dart'
    show WalletStats;

/// Mirrors the website `/wallet/statement` page via `/customer/reports/wallet`.
/// The endpoint is a Laravel paginator (20 rows per page), so pages are
/// loaded lazily instead of pretending the first page is the whole history.
class WalletStatementScreen extends ConsumerStatefulWidget {
  const WalletStatementScreen({super.key});

  @override
  ConsumerState<WalletStatementScreen> createState() =>
      _WalletStatementScreenState();
}

class _WalletStatementScreenState extends ConsumerState<WalletStatementScreen> {
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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
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
      final raw = await ref
          .read(customerRepositoryProvider)
          .reports('wallet', page: page == 1 ? null : '$page');
      final items = dataList(raw);
      final current = toInt(raw['current_page'], page);
      final last = toInt(raw['last_page'], current);
      final total = toInt(raw['total'], _items.length + items.length);
      if (!mounted) return;
      setState(() {
        if (!append) _items.clear();
        _items.addAll(items);
        _loadedPage = current;
        _lastPage = last;
        _total = total;
        _loading = false;
        _loadingMore = false;
        _error = null;
        _moreError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (append) {
          _moreError = true;
        } else {
          _error = 'تعذر تحميل كشف الحساب';
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
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: const Text('كشف حساب المحفظة')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _summary(lang),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('العمليات',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  _total > 0
                      ? 'عرض ${_items.length} من $_total'
                      : 'آخر 20 عملية لكل صفحة',
                  style: const TextStyle(
                      fontSize: 11, color: SahelColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._body(lang),
          ],
        ),
      ),
    );
  }

  Widget _summary(String lang) {
    final wallet = ref.watch(customerWalletProvider);
    return wallet.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SahelColors.surface,
          borderRadius: SahelRadii.mdRadius,
          border: Border.all(color: SahelColors.border),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text('تعذر تحميل ملخص الرصيد',
                  style: TextStyle(color: SahelColors.textMuted)),
            ),
            TextButton.icon(
              onPressed: () => ref.invalidate(customerWalletProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('إعادة المحاولة'.t(lang)),
            ),
          ],
        ),
      ),
      data: (w) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: SahelColors.primaryGradient,
              borderRadius: SahelRadii.mdRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرصيد الحالي'.t(lang),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SahelColors.onPrimary.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatMoney(w['balance'])} ${str(w['currency']).toUpperCase()}'
                      .trim(),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: SahelColors.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WalletStats(wallet: w),
        ],
      ),
    );
  }

  List<Widget> _body(String lang) {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Text(_error!, style: const TextStyle(color: SahelColors.textMuted)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: Text('إعادة المحاولة'.t(lang)),
              ),
            ],
          ),
        ),
      ];
    }
    if (_items.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('لا توجد عمليات في الكشف بعد',
                style: TextStyle(color: SahelColors.textMuted)),
          ),
        ),
      ];
    }
    return [
      for (final tx in _items) ...[
        _StatementRow(tx: tx),
        const Divider(height: 1, color: SahelColors.slate200),
      ],
      const SizedBox(height: 8),
      if (_loadingMore)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        )
      else if (_moreError)
        Center(
          child: TextButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('تعذر تحميل المزيد — إعادة المحاولة'),
          ),
        )
      else if (_loadedPage < _lastPage)
        Center(
          child: TextButton(
            onPressed: _loadMore,
            child: const Text('تحميل المزيد'),
          ),
        )
      else
        const Center(
          child: Text('تم عرض كل العمليات',
              style:
                  TextStyle(fontSize: 11, color: SahelColors.textMuted)),
        ),
    ];
  }
}

class _StatementRow extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _StatementRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = str(tx['type']).toLowerCase();
    final isCredit = type.contains('credit') || type.contains('topup');
    final isDebit = type.contains('debit') || type.contains('withdraw');
    final color = isCredit
        ? SahelColors.success
        : (isDebit ? SahelColors.danger : SahelColors.text);
    final desc = str(
      tx['description'] ?? tx['title'] ?? tx['notes'] ?? type,
      'عملية',
    );
    final amount = tx['formatted_amount'] != null
        ? str(tx['formatted_amount'])
        : formatMoney(tx['amount']);
    final balance = tx.containsKey('balance_after')
        ? formatMoney(tx['balance_after'])
        : strOrNull(tx['ending_balance']);
    final rawDate = tx['date_ar'] ??
        tx['formatted_created_at'] ??
        tx['created_at'];
    final formattedDate = formatDateTime(rawDate);
    final date = formattedDate.isNotEmpty ? formattedDate : str(rawDate);
    final status = str(tx['status']).toLowerCase();
    final statusLabel = switch (status) {
      'pending' => 'قيد المعالجة',
      'failed' => 'فشلت',
      'cancelled' || 'canceled' => 'ملغاة',
      _ => '',
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (date.isNotEmpty)
            Text(date,
                style: const TextStyle(
                    fontSize: 11, color: SahelColors.textMuted)),
          if (balance != null && balance != '—')
            Text('الرصيد بعد العملية: $balance',
                style: const TextStyle(
                    fontSize: 11, color: SahelColors.textMuted)),
          if (statusLabel.isNotEmpty)
            Text(statusLabel,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SahelColors.amber700)),
        ],
      ),
      trailing: Text(
        '${isDebit ? '−' : '+'}$amount',
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
      ),
      shape: const RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius),
    );
  }
}
