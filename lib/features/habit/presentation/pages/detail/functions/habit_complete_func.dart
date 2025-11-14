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

  // Check if month has changed since last completion
  bool monthChanged = false;
  if (habit.lastCompleted != null) {
    final lastCompleted = habit.lastCompleted!;
    monthChanged = lastCompleted.month != now.month || lastCompleted.year != now.year;
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

  int todayCount = 1;
  if (existingDayIndex >= 0) {
    // Update existing day
    todayCount = (updatedCompletedDays[existingDayIndex]['count'] as int) + 1;
    updatedCompletedDays[existingDayIndex] = {
      'date': todayString,
      'count': todayCount,
    };
  } else {
    // Add new day
    updatedCompletedDays.add({
      'date': todayString,
      'count': todayCount,
    });
  }

  // Handle month transition
  int newCountThisMonth = habit.countThisMonth;
  int newCountLastMonth = habit.countLastMonth;
  
  if (monthChanged) {
    // Month has changed, move current month to last month
    newCountLastMonth = habit.countThisMonth;
    newCountThisMonth = todayCount; // Reset for new month, starting with today's completion
  } else {
    // Same month, just increment current month count
    newCountThisMonth = habit.countThisMonth + 1;
    // Keep existing last month count
    newCountLastMonth = habit.countLastMonth;
  }

  // Calculate counts for current periods
  final currentYear = now.year;
  
  int thisWeekCount = 0;
  int thisYearCount = 0;
  
  for (final day in updatedCompletedDays) {
    final date = DateTime.parse(day['date']);
    final count = day['count'] as int;
    
    if (date.year == currentYear) {
      thisYearCount += count;
      
      // Calculate week (simple implementation)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        thisWeekCount += count;
      }
    }
  }

  // Calculate goal completion and records
  int newGoalCompletedCount = habit.goalCompletedCount + 1;
  int newGoalRecordCount = habit.goalRecordCount;
  
  // Update goal record if current completion count exceeds previous record
  if (newGoalCompletedCount > habit.goalRecordCount) {
    newGoalRecordCount = newGoalCompletedCount;
  }

  return habit.copyWith(
    goalCompletedCount: habit.goalCount,
    isCompleteToday: true,
    lastCompleted: today,
    streakCount: newStreak,
    bestStreak: newBestStreak,
    countThisMonth: newCountThisMonth,
    countLastMonth: newCountLastMonth,
    countThisWeek: thisWeekCount,
    countThisYear: thisYearCount,
    completedDays: updatedCompletedDays,
    goalRecordCount: newGoalRecordCount,
  );
}