import 'package:flutter/material.dart';


class AppColors {
  /* ==== DARK THEME ==== */
  /* Main */
  static const primaryDark = Color(0xFF22C55E);
  static const backgroundDark = Color(0xFF070707);
  static const surfaceDark = Color(0xFF202020);
  static const surfaceVariantDark = Color(0xFF131313);
  
  /* Text */
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF9A9A9A);
  static const onPrimary = Color(0xAA000000);
  static const onSurfaceVariant = Colors.white38;

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

  static const h2 = TextStyle(
    fontSize: 24,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const h3 = TextStyle(
    fontSize: 18,
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
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.errorDark,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      surfaceVariant: AppColors.surfaceVariantDark,
    ),

    scaffoldBackgroundColor: AppColors.backgroundDark,

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimaryDark),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
    ),

    dividerColor: AppColors.dividerDark,
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      indent: 0,
      endIndent: 0,
      space: 20,
    ),


    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
        foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark
      ),
    ),
  );

}