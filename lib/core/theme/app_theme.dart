import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Color Scheme - Dark Mode
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withValues(alpha: 0.2),
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textMain,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // AppBar Theme - Dark
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textMain,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textMain,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Card Theme - Glassmorphism
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),

    // Input Decoration Theme - Dark Mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
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
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: AppColors.textLight),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Data Table Theme - Dark
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
      dataRowColor: WidgetStateProperty.all(AppColors.surface),
      headingTextStyle: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dataTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      headingRowHeight: 48,
      dividerThickness: 1,
      horizontalMargin: 16,
      columnSpacing: 24,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),

    // Text Theme - Dark
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(
        color: AppColors.textMain,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // Eski uyumluluk için
  static final ThemeData lightTheme = darkTheme;
}
