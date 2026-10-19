import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahel_bottom_nav_item.dart';

class ProviderShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProviderShell({
    super.key,
    required this.navigationShell,
  });

  static const _destinations = [
    SahelNavDestination(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'الرئيسية'),
    SahelNavDestination(
        icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'الطلبات'),
    SahelNavDestination(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'الحجوزات'),
    SahelNavDestination(
        icon: Icons.attach_money_outlined,
        activeIcon: Icons.attach_money,
        label: 'الأرباح'),
    SahelNavDestination(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'الرسائل'),
  ];

  void _tap(int idx) {
    navigationShell.goBranch(
      idx,
      initialLocation: idx == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SahelBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _tap,
        destinations: _destinations,
      ),
    );
  }
}
