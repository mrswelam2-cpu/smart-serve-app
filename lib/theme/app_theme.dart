import 'package:flutter/material.dart';

class AppColors {
  static const primary    = Color(0xFF00B4B4);
  static const primaryDark = Color(0xFF0E7490);
  static const secondary  = Color(0xFF10B981);
  static const background = Color(0xFFF8FAFC);
  static const surface    = Color(0xFFFFFFFF);
  static const card       = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE2E8F0);
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted     = Color(0xFF94A3B8);
  static const error   = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const starColor = Color(0xFFFBBF24);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF00B4B4), Color(0xFF0E7490)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   AppColors.surface,
      error:     AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo'),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Cairo'),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
    ),
  );
}
