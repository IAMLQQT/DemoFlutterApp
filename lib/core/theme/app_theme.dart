import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';  

abstract final class AppTheme {
  static ThemeData get light => ThemeData (
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent, // avoid Material 3 tint on scroll
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
  );
}