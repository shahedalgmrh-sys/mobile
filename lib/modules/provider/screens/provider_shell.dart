import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import '../../../shared/widgets/sahel_bottom_nav_item.dart';

class ProviderShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ProviderShell({
    super.key,
    required this.navigationShell,
  });

  List<SahelNavDestination> _destinations(String lang) => [
        SahelNavDestination(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'الرئيسية'.t(lang)),
        SahelNavDestination(
            icon: Icons.inbox_outlined,
            activeIcon: Icons.inbox,
            label: 'الطلبات'.t(lang)),
        SahelNavDestination(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'الحجوزات'.t(lang)),
        SahelNavDestination(
            icon: Icons.attach_money_outlined,
            activeIcon: Icons.attach_money,
            label: 'الأرباح'.t(lang)),
        SahelNavDestination(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'الرسائل'.t(lang)),
      ];

  void _tap(int idx) {
    navigationShell.goBranch(
      idx,
      initialLocation: idx == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appSettingsProvider).language;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SahelBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _tap,
        destinations: _destinations(lang),
      ),
    );
  }
}
