import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class CustomerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({
    super.key,
    required this.navigationShell,
  });

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'),
    (icon: Icons.search_outlined, activeIcon: Icons.search, label: 'البحث'),
    (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'الحجوزات'),
    (icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'الرسائل'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'الملف الشخصي'),
  ];

  void _tap(int idx) {
    if (idx == 0) navigationShell.goBranch(0, initialLocation: idx == navigationShell.currentIndex);
    if (idx == 1) navigationShell.goBranch(1, initialLocation: idx == navigationShell.currentIndex);
    if (idx == 2) navigationShell.goBranch(2, initialLocation: idx == navigationShell.currentIndex);
    if (idx == 3) navigationShell.goBranch(3, initialLocation: idx == navigationShell.currentIndex);
    if (idx == 4) navigationShell.goBranch(4, initialLocation: idx == navigationShell.currentIndex);
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
