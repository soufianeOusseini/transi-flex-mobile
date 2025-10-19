import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

enum TravelStatus { confirmed, pending, completed, cancelled }

class TravelCard extends StatelessWidget {
  final String title;
  final String route;
  final int price;
  final String currency;
  final String date;
  final String time;
  final String seatInfo;
  final TravelStatus status;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onModifyTap;
  final bool showActionButtons;

  const TravelCard({
    Key? key,
    required this.title,
    required this.route,
    required this.price,
    this.currency = 'CFA',
    required this.date,
    required this.time,
    required this.seatInfo,
    required this.status,
    this.onDetailsTap,
    this.onModifyTap,
    this.showActionButtons = true,
  }) : super(key: key);

  Color get statusColor {
    switch (status) {
      case TravelStatus.confirmed:
        return AppColors.statusConfirmed;
      case TravelStatus.pending:
        return AppColors.statusPending;
      case TravelStatus.completed:
        return AppColors.statusCompleted;
      case TravelStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  String get statusText {
    switch (status) {
      case TravelStatus.confirmed:
        return 'confirmé';
      case TravelStatus.pending:
        return 'en_attente';
      case TravelStatus.completed:
        return 'terminé';
      case TravelStatus.cancelled:
        return 'annulé';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacingM),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          // Header avec gradient
          Container(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppStyles.radiusL),
                topRight: Radius.circular(AppStyles.radiusL),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.h3.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route,
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        seatInfo,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${price}",
                      style: AppStyles.h2.copyWith(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currency,
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
            child: Column(
              children: [
                // Date et statut
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.grey600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$date • $time',
                      style: AppStyles.bodyMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: AppStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (showActionButtons) ...[
                  const SizedBox(height: AppStyles.spacingM),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppStyles.spacingS),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDetailsTap,
                          style: AppStyles.outlineButton.copyWith(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          child: Text(
                            'Voir Détails',
                            style: AppStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}