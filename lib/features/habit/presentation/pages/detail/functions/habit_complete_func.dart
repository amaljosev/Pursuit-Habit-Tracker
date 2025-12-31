import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

Habit updateHabitOnCompletion(Habit habit) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Avoid duplicate completion
  if (habit.isCompleteToday &&
      habit.lastCompleted != null &&
      HelperFunctions.isToday(habit.lastCompleted!)) {
    return habit;
  }

  /// ---------- STREAK LOGIC ----------
  int newStreak;
  if (habit.lastCompleted == null) {
    newStreak = 1;
  } else if (HelperFunctions.isYesterday(habit.lastCompleted!)) {
    newStreak = habit.streakCount + 1;
  } else {
    newStreak = 1;
  }

  final newBestStreak =
      newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

  /// ---------- COMPLETED DAYS ----------
  final updatedCompletedDays =
      List<Map<String, dynamic>>.from(habit.completedDays);

  final todayKey = today.toIso8601String().split('T')[0];
  final index =
      updatedCompletedDays.indexWhere((e) => e['date'] == todayKey);

  if (index >= 0) {
    updatedCompletedDays[index]['count']++;
  } else {
    updatedCompletedDays.add({'date': todayKey, 'count': 1});
  }

  /// ---------- MONTH COUNTS ----------
  final lastCompleted = habit.lastCompleted;
  final monthChanged = lastCompleted != null &&
      (lastCompleted.month != now.month ||
          lastCompleted.year != now.year);

  int newCountThisMonth;
  int newCountLastMonth;

  if (monthChanged) {
    newCountLastMonth = habit.countThisMonth;
    newCountThisMonth = 1;
  } else {
    newCountThisMonth = habit.countThisMonth + 1;
    newCountLastMonth = habit.countLastMonth;
  }

  /// ---------- WEEK & YEAR CALCULATION ----------
int countThisWeek = 0;
int countLastWeek = 0;
int countThisYear = 0;
int countLastYear = 0;

// Sunday-based week calculation
// Dart weekday: Mon=1 ... Sun=7
final int sundayOffset = today.weekday % 7;

final startOfThisWeek =
    DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: sundayOffset));
final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));

final startOfLastWeek =
    startOfThisWeek.subtract(const Duration(days: 7));
final endOfLastWeek =
    startOfThisWeek.subtract(const Duration(days: 1));

for (final day in updatedCompletedDays) {
  final date = DateTime.parse(day['date']);
  final count = day['count'] as int;

  // Year counts
  if (date.year == now.year) {
    countThisYear += count;
  } else if (date.year == now.year - 1) {
    countLastYear += count;
  }

  // Week counts (Sunday → Saturday)
  if (!date.isBefore(startOfThisWeek) &&
      !date.isAfter(endOfThisWeek)) {
    countThisWeek += count;
  } else if (!date.isBefore(startOfLastWeek) &&
      !date.isAfter(endOfLastWeek)) {
    countLastWeek += count;
  }
}


  /// ---------- GOAL RECORD ----------
  final newGoalRecordCount =
      habit.goalCompletedCount > habit.goalRecordCount
          ? habit.goalCompletedCount
          : habit.goalRecordCount;

  return habit.copyWith(
    goalCompletedCount: habit.goalCount,
    isCompleteToday: true,
    lastCompleted: today,
    streakCount: newStreak,
    bestStreak: newBestStreak,
    countThisMonth: newCountThisMonth,
    countLastMonth: newCountLastMonth,
    countThisWeek: countThisWeek,
    countLastWeek: countLastWeek,
    countThisYear: countThisYear,
    countLastYear: countLastYear,
    completedDays: updatedCompletedDays,
    goalRecordCount: newGoalRecordCount,
  );
}
