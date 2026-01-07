import 'package:pursuit/features/habit/domain/entities/habit.dart';

bool isHabitEndingToday(Habit habit) {
  if (habit.endDate == null) return false;

  try {
    final DateTime endDate = habit.endDate!;
    final DateTime today = DateTime.now();

    return endDate.year == today.year &&
        endDate.month == today.month &&
        endDate.day == today.day;
  } catch (e) {
    // If parsing fails
    return false;
  }
}
