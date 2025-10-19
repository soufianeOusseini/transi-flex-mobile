import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentification/cubit/auth_cubit.dart';
import '../../authentification/model/user_role.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_styles.dart';
import '../../shared/bottom_nav_bar.dart';
import '../../shared/custom_app_bar.dart';
import '../../shared/custum_drawer.dart';
import '../../shared/menu.dart';
import '../../shared/menu_manager.dart';

class MainScreen extends StatefulWidget {
  final UserRole userRole;

  const MainScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation vers la page correspondante
    List<Menu> menus = MenuManager.getBottomNavigationMenus(widget.userRole);
    String route = menus[index].route;
    // Navigator.pushNamed(context, route);
  }

  void _onMenuTap(String route) {
    if (route == '/logout') {
      context.read<AuthCubit>().logout();
      return;
    }
    // Navigation vers la page correspondante
    // Navigator.pushNamed(context, route);
    print('Navigation vers: $route');
  }

  @override
  Widget build(BuildContext context) {
    List<Menu> bottomMenus = MenuManager.getBottomNavigationMenus(widget.userRole);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.grey50,
          appBar: CustomAppBar(
            title: 'Transi-Flex',
            subtitle: _getSubtitleForRole(widget.userRole),
            onNotificationTap: () {
              print('Notifications tappées');
            },
            onProfileTap: () {
              print('Profil tappé');
            },
          ),
          // drawer: CustomDrawer(
          //   user: (state is AuthAuthenticated) ? state.user : null,
          //   userRole: widget.userRole,
          //   onMenuTap: _onMenuTap,
          // ),
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppStyles.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône principale
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForCurrentPage(bottomMenus[_currentIndex]),
                    color: AppColors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: AppStyles.spacingL),

                // Titre de la page
                Text(
                  bottomMenus[_currentIndex].title,
                  style: AppStyles.h1.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppStyles.spacingM),

                // Information sur le rôle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacingM,
                    vertical: AppStyles.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusL),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Rôle: ${_getRoleDisplayName(widget.userRole)}',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: AppStyles.spacingXL),

                // Description ou informations supplémentaires
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacingM),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.grey600,
                        size: 24,
                      ),
                      const SizedBox(height: AppStyles.spacingS),
                      Text(
                        _getDescriptionForCurrentPage(bottomMenus[_currentIndex]),
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            userRole: widget.userRole,
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
          ),
        );
      },
    );
  }

  String _getSubtitleForRole(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return 'Interface passager';
      case UserRole.DRIVER:
        return 'Interface conducteur';
      case UserRole.ADMIN:
        return 'Interface administrateur';
      default:
        return '';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return 'Client';
      case UserRole.DRIVER:
        return 'Conducteur';
      case UserRole.ADMIN:
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  IconData _getIconForCurrentPage(Menu menu) {
    return menu.icon ?? Icons.home;
  }

  String _getDescriptionForCurrentPage(Menu menu) {
    // Vous pouvez personnaliser les descriptions selon les pages
    switch (menu.route) {
      case '/home':
        return 'Bienvenue sur votre tableau de bord principal';
      case '/search':
        return 'Recherchez et réservez vos trajets';
      case '/trips':
        return 'Gérez tous vos voyages';
      case '/profile':
        return 'Consultez et modifiez votre profil';
      default:
        return 'Page ${menu.title}';
    }
  }
}