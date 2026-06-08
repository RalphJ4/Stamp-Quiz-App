import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
      );
}
