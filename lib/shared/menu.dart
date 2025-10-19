import 'package:flutter/cupertino.dart';

class Menu {
  final String title;
  final IconData icon;
  final String route;
  final bool isActive;
  final int? badge;

  Menu({
    required this.title,
    required this.icon,
    required this.route,
    this.isActive = true,
    this.badge
  });
}