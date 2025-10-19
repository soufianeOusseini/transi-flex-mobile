import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppStyles.spacingM),
        decoration: AppStyles.cardDecoration.copyWith(
          color: backgroundColor ?? AppColors.cardBackground,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: AppStyles.spacingS),
            Text(
              title,
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Widget? trailing;

  const HorizontalActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.spacingS),
        padding: const EdgeInsets.all(AppStyles.spacingM),
        decoration: AppStyles.cardDecoration.copyWith(
          color: backgroundColor ?? AppColors.cardBackground,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppStyles.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            const Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}