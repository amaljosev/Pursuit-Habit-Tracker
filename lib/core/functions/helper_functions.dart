import 'package:flutter/material.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/constants/habit_measures.dart';
import 'package:pursuit/features/habit/constants/habit_timings.dart';
import 'package:pursuit/features/habit/constants/habit_types.dart';

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
      return HabitTypes.types.firstWhere(
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

  static String getMeasureTypeById(int id) {
    try {
      return HabitMeasures.measures.firstWhere(
            (emoji) => emoji['id'] == id,
          )['type'] ??
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

  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  static String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    return "$day-$month-${date.year}";
  }
}
