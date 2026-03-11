import 'package:pursuit/features/habit/domain/entities/habit.dart';

bool isHabitEndingToday(Habit habit) {
  if (habit.endDate == null) return false;
  final end = habit.endDate!;
  final today = DateTime.now();
  return end.year == today.year &&
      end.month == today.month &&
      end.day == today.day;
}