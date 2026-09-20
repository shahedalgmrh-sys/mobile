import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/shared/widgets/sahel_bottom_nav_item.dart';
import 'package:saber_flutter/modules/customer/screens/home/home_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/search_screen.dart';
import 'package:saber_flutter/modules/customer/screens/bookings/bookings_list_screen.dart';
import 'package:saber_flutter/modules/customer/screens/profile/customer_profile_screen.dart';

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key});

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    BookingsListScreen(),
    Center(child: Text('Inbox', style: TextStyle(fontSize: 24))),
    CustomerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: isLandscape
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (i) => setState(() => _currentIndex = i),
                  backgroundColor: SahelColors.surface,
                  elevation: 8,
                  selectedIconTheme: const IconThemeData(color: SahelColors.primary700),
                  unselectedIconTheme: IconThemeData(color: SahelColors.textMuted),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('الرئيسية'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      selectedIcon: Icon(Icons.search),
                      label: Text('البحث'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.schedule),
                      selectedIcon: Icon(Icons.schedule),
                      label: Text('حجوزاتي'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble),
                      label: Text('الرسائل'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('حسابي'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              selectedItemColor: SahelColors.primary700,
              unselectedItemColor: SahelColors.textMuted,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              items: [
                SahelBottomNavItem(
                  iconData: Icons.home_outlined,
                  activeIconData: Icons.home,
                  labelText: 'الرئيسية',
                ),
                SahelBottomNavItem(
                  iconData: Icons.search,
                  labelText: 'البحث',
                ),
                SahelBottomNavItem(
                  iconData: Icons.schedule,
                  activeIconData: Icons.schedule,
                  labelText: 'حجوزاتي',
                ),
                SahelBottomNavItem(
                  iconData: Icons.chat_bubble_outline,
                  activeIconData: Icons.chat_bubble,
                  labelText: 'الرسائل',
                ),
                SahelBottomNavItem(
                  iconData: Icons.person_outline,
                  activeIconData: Icons.person,
                  labelText: 'حسابي',
                ),
              ],
            ),
    );
  }
}
