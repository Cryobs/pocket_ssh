import 'package:flutter/material.dart';


class AppColors {
  /* ==== DARK THEME ==== */
  /* Main */
  static const primaryDark = Color(0xFF22C55E);
  static const backgroundDark = Color(0xFF070707);
  static const surfaceDark = Color(0xFF202020);
  static const surfaceVariantDark = Color(0xFF070707);
  
  /* Text */
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF676767);

  /* Additional */
  static const warningDark = Color(0xFFE5A50A);
  static const errorDark = Color(0xFFE9220C);
  static const successDark = Color(0xFF22C55E);

  /* Divider */
  static const dividerDark = Color(0xFF676767);

}

class AppTextStyles {
  /* Headers */
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.3,
  );

  /* Body */
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}

class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,

  );

}