import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      surface: AppColors.charcoalBlack,
      onSurface: AppColors.textPrimaryDark,
      primary: AppColors.sunsetCopper,
      onPrimary: AppColors.charcoalBlack,
      secondary: AppColors.sageGreen,
      onSecondary: AppColors.charcoalBlack,
      error: AppColors.priorityCritical,
      onError: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.charcoalBlack,
      cardColor: AppColors.obsidianSlate,
      dividerColor: AppColors.dividerDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoalBlack,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headline(AppColors.textPrimaryDark),
        titleMedium: AppTextStyles.sectionTitle(AppColors.textPrimaryDark),
        bodyLarge: AppTextStyles.taskTitle(AppColors.textPrimaryDark),
        bodyMedium: AppTextStyles.body(AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.caption(AppColors.textSecondaryDark),
        labelLarge: AppTextStyles.button(AppColors.charcoalBlack),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunsetCopper,
          foregroundColor: AppColors.charcoalBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.obsidianSlate,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.body(AppColors.textSecondaryDark),
      ),
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      surface: AppColors.lightBackground,
      onSurface: AppColors.textPrimaryLight,
      primary: AppColors.sunsetCopper,
      onPrimary: Colors.white,
      secondary: AppColors.sageGreen,
      onSecondary: Colors.white,
      error: AppColors.priorityCritical,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.dividerLight,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headline(AppColors.textPrimaryLight),
        titleMedium: AppTextStyles.sectionTitle(AppColors.textPrimaryLight),
        bodyLarge: AppTextStyles.taskTitle(AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.body(AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.caption(AppColors.textSecondaryLight),
        labelLarge: AppTextStyles.button(Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunsetCopper,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        hintStyle: AppTextStyles.body(AppColors.textSecondaryLight),
      ),
    );
  }
}