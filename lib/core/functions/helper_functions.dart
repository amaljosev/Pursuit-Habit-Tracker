import 'package:flutter/material.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_category.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/constants/habit_measures.dart';
import 'package:pursuit/features/habit/constants/habit_timings.dart';

class HelperFunctions {
  static String getEmojiById(int id) {
    try {
      return HabitIcons.emojis.firstWhere(
            (emoji) => emoji['id'] == id,
          )['emoji'] ??
          '❓';
    } catch (e) {
      return '❓';
    }
  }

  static Color getColorById({required int id, bool? isDark}) {
    final match = isDark != null
        ? AppColors.darkColors.firstWhere(
            (item) => item["id"] == id,
            orElse: () => {"color": Colors.grey[300]!},
          )
        : AppColors.lightColors.firstWhere(
            (item) => item["id"] == id,
            orElse: () => {"color": Colors.grey[300]!},
          );
    return match["color"];
  }

  static String getTypeById(int id) {
    try {
      return HabitCategory.categories.firstWhere(
            (emoji) => emoji['id'] == id,
          )['name'] ??
          '❓';
    } catch (e) {
      return '❓';
    }
  }

  static String getMeasureById(int id) {
    try {
      return HabitMeasures.measures.firstWhere(
            (emoji) => emoji['id'] == id,
          )['name'] ??
          '❓';
    } catch (e) {
      return '❓';
    }
  }
  static String getTimingById(int id) {
    try {
      return HabitTimings.times.firstWhere(
            (emoji) => emoji['id'] == id,
          )['name'] ??
          '❓';
    } catch (e) {
      return '❓';
    }
  }
}
