import 'package:flutter/material.dart';

import '../authentification/model/user_role.dart';
import 'menu.dart';
import 'menu_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final UserRole userRole;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.userRole,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Menu> menus = MenuManager.getBottomNavigationMenus(userRole);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: menus.map((menu) => BottomNavigationBarItem(
        icon: Icon(menu.icon),
        label: menu.title,
      )).toList(),
    );
  }
}