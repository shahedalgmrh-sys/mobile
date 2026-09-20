import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProviderShell({
    super.key,
    required this.navigationShell,
  });

  static const _items = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'الرئيسية'),
    (icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'الطلبات'),
    (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'الحجوزات'),
    (icon: Icons.attach_money_outlined, activeIcon: Icons.attach_money, label: 'الأرباح'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'الحساب'),
  ];

  void _tap(int idx) {
    navigationShell.goBranch(idx, initialLocation: idx == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _tap,
        items: _items
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e.icon),
                  activeIcon: Icon(e.activeIcon, color: SahelColors.primary600),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}
