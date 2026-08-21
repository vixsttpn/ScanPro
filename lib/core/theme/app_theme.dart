
import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF000000);
  static const surface = Color(0xFF0A0A0A);
  static const surface2 = Color(0xFF141414);
  static const border = Color(0xFF1E1E1E);
  static const text = Color(0xFFFFFFFF);
  static const text2 = Color(0xFF8A8A8A);
  static const text3 = Color(0xFF4A4A4A);
  static const accent = Color(0xFFFFFFFF);
  static const error = Color(0xFFFF3B30);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        background: AppColors.bg,
        surface: AppColors.surface,
        primary: AppColors.accent,
        onPrimary: AppColors.bg,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrimColor: Colors.transparent,
        titleTextStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 17, color: AppColors.text),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 28, letterSpacing: -0.5, color: AppColors.text),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.text),
        titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.text),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 15, color: AppColors.text),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.text2),
        labelSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5, color: AppColors.text3),
      ),
      dividerColor: AppColors.border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

class AppDurations {
  static const ui = Duration(milliseconds: 220);
  static const transition = Duration(milliseconds: 350);
  static const curve = Curves.easeOutExpo;
}
