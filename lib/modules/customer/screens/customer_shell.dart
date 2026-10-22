import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import '../../../shared/widgets/sahel_bottom_nav_item.dart';

class CustomerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CustomerShell({
    super.key,
    required this.navigationShell,
  });

  List<SahelNavDestination> _destinations(String lang) => [
        SahelNavDestination(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'الرئيسية'.t(lang)),
        SahelNavDestination(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'الحجوزات'.t(lang)),
        SahelNavDestination(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'الرسائل'.t(lang)),
        SahelNavDestination(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'حسابي'.t(lang)),
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
