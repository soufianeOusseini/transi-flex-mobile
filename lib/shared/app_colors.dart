import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF0D6EFD);
  static const Color primaryLight = Color(0xFF73B3F2);
  static const Color primaryDark = Color(0xFF2E5A8A);

  // Gradient principal (bleu vers turquoise)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF0D6EFD),
      Color(0xFF00BCD4),
    ],
  );

  // Couleurs de statut
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Couleurs spécifiques à l'app
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Status colors pour les voyages
  static const Color statusConfirmed = Color(0xFF4CAF50);
  static const Color statusPending = Color(0xFFFFC107);
  static const Color statusCompleted = Color(0xFF2196F3);
  static const Color statusCancelled = Color(0xFFF44336);

  // Couleurs pour les badges
  static Color getBadgeColor(int count) {
    if (count == 0) return grey400;
    if (count <= 5) return warning;
    if (count <= 10) return primary;
    return error;
  }
}