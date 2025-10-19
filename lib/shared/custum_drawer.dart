
import 'package:flutter/material.dart';
import '../authentification/model/user_role.dart';
import '../shared/menu_manager.dart';
import '../shared/menu.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class CustomDrawer extends StatelessWidget {
  final dynamic user;
  final UserRole userRole;
  final Function(String) onMenuTap;

  const CustomDrawer({
    Key? key,
    required this.user,
    required this.userRole,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Menu> drawerMenus = MenuManager.getDrawerMenus(userRole);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: AppStyles.spacingL,
              right: AppStyles.spacingL,
              bottom: AppStyles.spacingL,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 35,
                  ),
                ),

                const SizedBox(height: AppStyles.spacingM),

                // Nom d'utilisateur
                Text(
                  user?.firstName != null ? '${user.firstName} ${user.lastName ?? ''}' : 'Jean Dupont',
                  style: AppStyles.h3.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 4),

                // Rôle
                Text(
                  userRole.toString().split('.').last.toUpperCase(),
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: AppStyles.spacingS),

                // Étoiles de notation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close button
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(AppStyles.spacingS),
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Menu title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingL),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENU',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppStyles.spacingS),

          // Menu items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingL),
              itemCount: drawerMenus.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final menu = drawerMenus[index];
                return _buildMenuItem(context, menu);
              },
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppStyles.spacingL),
            child: Divider(color: AppColors.divider),
          ),

          // Bottom menu items
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingL),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  Menu(
                    title: 'Aide & Support',
                    icon: Icons.help_outline,
                    route: '/help',
                  ),
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context,
                  Menu(
                    title: 'Paramètres',
                    icon: Icons.settings_outlined,
                    route: '/settings',
                  ),
                ),
                const SizedBox(height: AppStyles.spacingM),
                _buildMenuItem(
                  context,
                  Menu(
                    title: 'Déconnexion',
                    icon: Icons.logout,
                    route: '/logout',
                  ),
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Menu menu, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onMenuTap(menu.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppStyles.spacingM,
          horizontal: AppStyles.spacingS,
        ),
        child: Row(
          children: [
            Icon(
              menu.icon,
              color: isLogout ? AppColors.error : AppColors.grey700,
              size: 22,
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Text(
                menu.title,
                style: AppStyles.bodyMedium.copyWith(
                  color: isLogout ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (menu.badge != null && menu.badge! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  menu.badge.toString(),
                  style: AppStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}