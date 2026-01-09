import 'package:flutter/material.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/constants/habit_measures.dart';
import 'package:pursuit/features/habit/constants/habit_timings.dart';
import 'package:pursuit/features/habit/constants/habit_types.dart';

class HelperFunctions {
  static Map<int, String>? _emojiCache;

  static String getEmojiById(int id) {
    // Initialize cache if null
    if (_emojiCache == null) {
      _emojiCache = {};
      for (final emoji in HabitIcons.emojis) {
        final emojiId = emoji['id'] as int;
        final emojiChar = emoji['emoji'] as String;
        _emojiCache![emojiId] = emojiChar;
      }
    }

    // Return from cache or default
    return _emojiCache![id] ?? '❓';
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

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static DateTime? parse12HourTime(String timeString) {
    try {
      final now = DateTime.now();

      final parts = timeString.trim().split(' ');
      if (parts.length != 2) return null;

      final timePart = parts[0]; // 2:40
      final period = parts[1].toUpperCase(); // AM / PM

      final timeParts = timePart.split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);

      // ⛔ If time already passed today → schedule for tomorrow
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      return scheduled;
    } catch (_) {
      return null;
    }
  }
}
