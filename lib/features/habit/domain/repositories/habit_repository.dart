// domain/repositories/habit_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<Either<Failure, void>> insertHabit(Habit habit);
  Future<Either<Failure, List<Habit>>> getAllHabits();
  Future<Either<Failure, void>> deleteHabit(String id);
  Future<Either<Failure, void>> updateHabit(Habit habit);
  Future<Either<Failure, Habit?>> getHabitById(String id);

  /// Increment/decrement the count for today (used by existing GoalCountUpdateEvent).
  Future<Either<Failure, void>> updateGoalCount({
    required String id,
    required int value,
  });

  /// Core historical-tracking write operation.
  /// Marks [date] on habit [id] with [count] taps and [isCompleted] status.
  /// Recalculates streak, bestStreak, and all count* statistics afterwards.
  Future<Either<Failure, Habit>> markHabitForDate({
    required String id,
    required DateTime date,
    required int count,
    required bool isCompleted,
  });

  /// Returns all habits that were active on [date]
  /// (startDate ≤ date AND (endDate == null OR endDate ≥ date)).
  Future<Either<Failure, List<Habit>>> getHabitsForDate(DateTime date);
}