import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
  cardColor: AppColors.lightCardBackground,
  dividerColor: AppColors.lightDivider,

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.shifting,
    backgroundColor: AppColors.lightCardBackground,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.grey.shade600,
    showUnselectedLabels: true,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
    elevation: 8,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
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
      color: AppColors.lightTextColor,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextColor,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextColor,
    ),

    // Headline
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    ),

    // Titles
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      color: AppColors.lightTextColor,
    ),

    // Body (Inter)
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      color: AppColors.lightTextColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: AppColors.lightTextColor,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      color: AppColors.lightSecondaryText,
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
  tabBarTheme: TabBarThemeData(
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
    indicator: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    splashBorderRadius: const BorderRadius.all(Radius.circular(20)),
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: AppColors.lightCardBackground
    )
  ),

  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.lightCardBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: AppColors.lightTextColor,
  ),
);
