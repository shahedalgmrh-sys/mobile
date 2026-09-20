import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/modules/provider/screens/provider_dashboard_screen.dart';
import 'package:saber_flutter/modules/provider/screens/booking_requests_feed_screen.dart';
import 'package:saber_flutter/modules/provider/screens/earnings_and_payout_screen.dart';

class ProviderShell extends ConsumerStatefulWidget {
  const ProviderShell({super.key});

  @override
  ConsumerState<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends ConsumerState<ProviderShell> {
  int _currentIndex = 0;
  bool _availabilityMode = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    ProviderDashboardScreen(),
    BookingRequestsFeedScreen(),
    EarningsAndPayoutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(gradient: SahelColors.nightGradient),
              currentAccountPicture: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: SahelColors.primary100,
                    child: const Icon(Icons.person, color: SahelColors.primary700, size: 44),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: SahelColors.success,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
              accountName: const Row(
                children: [
                  Text(
                    'خدمات ساحل للصيانة',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: SahelColors.primary300, size: 16),
                ],
              ),
              accountEmail: const Text('+967 777 987 654'),
            ),
            _drawerTile(Icons.dashboard_outlined, Icons.dashboard, 'لوحة التحكم', 0),
            _drawerTile(Icons.inbox_outlined, Icons.inbox, 'طلبات الحجز', 1),
            _drawerTile(Icons.calendar_month_outlined, Icons.calendar_month, 'التقويم والمواعيد', null),
            _drawerTile(Icons.miscellaneous_services_outlined, Icons.miscellaneous_services, 'خدماتي ومعرض الأعمال', null),
            _drawerTile(Icons.people_outline, Icons.people, 'فريق العمل', null),
            _drawerTile(Icons.star_border, Icons.star, 'التقييمات والمراجعات', null),
            _drawerTile(Icons.chat_bubble_outline, Icons.chat_bubble, 'الرسائل', null),
            _drawerTile(Icons.report_gmailerrorred_outlined, Icons.report_gmailerrorred, 'الشكاوى والوساطة', null),
            _drawerTile(Icons.campaign_outlined, Icons.campaign, 'مركز الترويج والعروض', null),
            _drawerTile(Icons.analytics_outlined, Icons.analytics, 'التقارير والتحليلات', null),
            const Divider(),
            _drawerTile(Icons.settings_outlined, Icons.settings, 'الإعدادات', null),
            _drawerTile(Icons.verified_user_outlined, Icons.verified_user, 'حالة توثيق الحساب (KYC)', null),
            _drawerTile(Icons.workspace_premium_outlined, Icons.workspace_premium, 'الاشتراك المميز', null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: SahelColors.textMuted, size: 22),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'إيقاف استقبال الحجوزات مؤقتاً',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  Switch(
                    value: !_availabilityMode,
                    onChanged: (v) => setState(() => _availabilityMode = !v),
                    activeTrackColor: SahelColors.danger.withOpacity(0.4),
                    activeThumbImage: null,
                    activeColor: SahelColors.danger,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: SahelColors.danger),
              title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.danger)),
              onTap: () => _showLogoutConfirm(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          ['لوحة التحكم', 'طلبات الحجز', 'أرباحي'][_currentIndex],
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: SahelColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: SahelColors.primary700,
        unselectedItemColor: SahelColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: 'الحجوزات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'الأرباح',
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, IconData activeIcon, String title, int? index) {
    final selected = index != null;
    return ListTile(
      leading: Icon(selected && index == _currentIndex ? activeIcon : icon, color: selected && index == _currentIndex ? SahelColors.primary700 : SahelColors.textMuted),
      title: Text(title, style: TextStyle(fontWeight: selected && index == _currentIndex ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
      selected: selected && index == _currentIndex,
      selectedColor: SahelColors.primary700,
      selectedTileColor: SahelColors.primary50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: index != null
          ? () {
              setState(() => _currentIndex = index);
              Navigator.of(context).pop();
            }
          : () {},
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
        title: const Row(
          children: [
            Icon(Icons.logout, color: SahelColors.danger),
            SizedBox(width: 8),
            Text('تأكيد الخروج', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من تسجيل الخروج؟'),
            SizedBox(height: 8),
            Text(
              'سيتم إيقاف استقبال الحجوزات تلقائياً.',
              style: TextStyle(fontSize: 12, color: SahelColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: SahelColors.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius)),
            child: const Text('خروج وتعطيل', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
