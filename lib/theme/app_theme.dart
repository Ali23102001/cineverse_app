import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1A);
  static const card = Color(0xFF1E1E1E);
  static const red = Color(0xFFE53935);
  static const redDark = Color(0xFFB71C1C);
  static const gold = Color(0xFFFFC107);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFAAAAAA);
  static const textHint = Color(0xFF666666);
  static const border = Color(0xFF2A2A2A);
}

class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.red,
          surface: AppColors.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
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
            borderSide: const BorderSide(color: AppColors.red, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.textHint),
        ),
      );
}
