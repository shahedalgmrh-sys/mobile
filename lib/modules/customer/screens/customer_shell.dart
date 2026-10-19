import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahel_bottom_nav_item.dart';

class CustomerShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({
    super.key,
    required this.navigationShell,
  });

  static const _destinations = [
    SahelNavDestination(
        icon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'),
    SahelNavDestination(
        icon: Icons.search_outlined, activeIcon: Icons.search, label: 'البحث'),
    SahelNavDestination(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'الحجوزات'),
    SahelNavDestination(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'الرسائل'),
    SahelNavDestination(
        icon: Icons.person_outline, activeIcon: Icons.person, label: 'حسابي'),
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
