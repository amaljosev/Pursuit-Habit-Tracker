import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData darkTheme = ThemeData.dark().copyWith(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
  cardColor: AppColors.darkCardBackground,
  dividerColor: AppColors.darkDivider,

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.shifting,
    backgroundColor: AppColors.darkCardBackground,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: Colors.grey.shade500,
    showUnselectedLabels: true,
    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    elevation: 8,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkCardBackground,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),
  ),

  textTheme: const TextTheme(
    // Display
    displayLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),

    // Headlines
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),

    // Titles
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),

    // Body (Inter)
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      color: AppColors.darkTextColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: AppColors.darkTextColor,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      color: AppColors.darkSecondaryText,
    ),

    // Labels & Buttons (Nunito)
    labelLarge: TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryLight,
    secondary: AppColors.accent,
    surface: AppColors.darkCardBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: AppColors.darkTextColor,
  ),
);
