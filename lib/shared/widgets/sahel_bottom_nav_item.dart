import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';

class SahelBottomNavItem extends BottomNavigationBarItem {
  final IconData activeIconData;
  final IconData iconData;
  final String labelText;

  SahelBottomNavItem({
    required this.iconData,
    required this.labelText,
    IconData? activeIconData,
  })  : activeIconData = activeIconData ?? iconData,
        super(
          icon: Icon(iconData, size: 24),
          activeIcon: Icon(activeIconData ?? iconData, size: 26),
          label: labelText,
        );
}
