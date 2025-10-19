import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.subtitle = '',
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Menu/Back button
                if (showBackButton)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                // else
                //   Builder(
                //     builder: (context) => IconButton(
                //       icon: const Icon(Icons.menu, color: AppColors.white),
                //       onPressed: () => Scaffold.of(context).openDrawer(),
                //     ),
                //   ),

                // Title and subtitle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.h3.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}