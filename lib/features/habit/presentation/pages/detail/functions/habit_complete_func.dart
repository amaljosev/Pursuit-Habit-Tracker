import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

Habit updateHabitOnCompletion(Habit habit) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Check if already completed today to avoid duplicate updates
  if (habit.isCompleteToday && 
      habit.lastCompleted != null && 
      HelperFunctions.isToday(habit.lastCompleted!)) {
    return habit;
  }

  // Calculate new streak
  int newStreak = habit.streakCount;
  if (habit.lastCompleted == null) {
    // First time completion
    newStreak = 1;
  } else if (HelperFunctions.isToday(habit.lastCompleted!)) {
    // Already completed today, keep current streak
    newStreak = habit.streakCount;
  } else if (HelperFunctions.isYesterday(habit.lastCompleted!)) {
    // Completed yesterday, increment streak
    newStreak = habit.streakCount + 1;
  } else {
    // Streak broken, reset to 1
    newStreak = 1;
  }

  // Update best streak if current streak is higher
  final newBestStreak = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

  // Update completed days
  final List<Map<String, dynamic>> updatedCompletedDays = List.from(habit.completedDays);
  
  // Check if today already exists in completedDays
  final todayString = today.toIso8601String().split('T')[0];
  final existingDayIndex = updatedCompletedDays.indexWhere(
    (day) => day['date'] == todayString
  );

  if (existingDayIndex >= 0) {
    // Update existing day
    updatedCompletedDays[existingDayIndex] = {
      'date': todayString,
      'count': (updatedCompletedDays[existingDayIndex]['count'] as int) + 1,
    };
  } else {
    // Add new day
    updatedCompletedDays.add({
      'date': todayString,
      'count': 1,
    });
  }

  // Get current period counts
  final currentMonth = now.month;
  final currentYear = now.year;
  
  // Calculate counts for current periods
  int thisMonthCount = 0;
  int thisWeekCount = 0;
  int thisYearCount = 0;
  
  for (final day in updatedCompletedDays) {
    final date = DateTime.parse(day['date']);
    final count = day['count'] as int;
    
    if (date.year == currentYear) {
      thisYearCount += count;
      
      if (date.month == currentMonth) {
        thisMonthCount += count;
      }
      
      // Calculate week (simple implementation - you might want to use a proper week calculation)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        thisWeekCount += count;
      }
    }
  }

  return habit.copyWith(
    goalCompletedCount: habit.goalCount, // Set to max since completed
    isCompleteToday: true,
    lastCompleted: today,
    streakCount: newStreak,
    bestStreak: newBestStreak,
    countThisMonth: thisMonthCount,
    countThisWeek: thisWeekCount,
    countThisYear: thisYearCount,
    completedDays: updatedCompletedDays,
    // Update goal record if current completion exceeds previous record
    goalRecordCount: habit.goalCompletedCount > habit.goalRecordCount 
        ? habit.goalCompletedCount 
        : habit.goalRecordCount,
  );
}