import 'package:flutter/material.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';

class HelperFunctions {
  static String getEmojiById(int id) {
    try {
      return HabitIcons.emojis.firstWhere((emoji) => emoji['id'] == id)['emoji'] ?? '❓';
    } catch (e) {
      return '❓';
    }
  }
  static Color getColorById(int id) {
    final match = AppColors.lightColors.firstWhere(
      (item) => item["id"] == id,
      orElse: () => {"color": Colors.grey[300]!}, 
    );
    return match["color"];
  }
}