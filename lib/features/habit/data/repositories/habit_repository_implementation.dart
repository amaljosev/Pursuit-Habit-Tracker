import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:pursuit/core/utils/date_utils.dart';
import 'package:pursuit/core/utils/shared_prefs_utils.dart';
import 'package:pursuit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:pursuit/features/habit/data/models/habit_model.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> insertHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.insertHabit(model);
      return const Right(null);
    } catch (e) {
      log(e.toString());
      return Left(DatabaseFailure(message: 'Failed to insert habit: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Habit>>> getAllHabits() async {
    try {
      final models = await localDataSource.getAllHabits();
      final habits = models.map((m) => m.toEntity()).toList();
      return Right(habits);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to fetch habits: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.updateHabit(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update habit: $e'));
    }
  }

  @override
  Future<Either<Failure, Habit?>> getHabitById(String id) async {
    try {
      final model = await localDataSource.getHabitById(id);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGoalCount({
    required String id,
    required int value,
  }) async {
    try {
      await localDataSource.updateHabitField(
        id: id,
        fieldName: 'goalCompletedCount',
        newValue: value,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update goal count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> checkAndPerformDailyReset() async {
    try {
      // Check if reset is needed
      final needsReset = await _needsDailyReset();

      if (!needsReset) {
        return const Right(null);
      }

      // Get all habits from database
      final habits = await localDataSource.getAllHabits();

      // Reset each habit for new day
      final updatedHabits = habits.map(_resetHabitForNewDay).toList();

      // Update all habits in database
      for (final habit in updatedHabits) {
        await localDataSource.updateHabit(habit);
      }

      // Update last reset date
      await SharedPrefsUtils.setLastResetDate(DateTime.now());

      debugPrint('✅ Daily reset completed for ${habits.length} habits');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ Daily reset failed: $e');
      return Left(
        DatabaseFailure(message: 'Failed to perform daily reset: $e'),
      );
    }
  }

  Future<bool> _needsDailyReset() async {
    final lastResetString = await SharedPrefsUtils.getLastResetDate();

    if (lastResetString == null) {
      // First time - set today as reset date
      await SharedPrefsUtils.setLastResetDate(DateTime.now());
      return false;
    }

    final lastReset = DateTime.parse(lastResetString);
    final today = DateTime.now();

    // Check if we're on a different day
    return !DateUtils.isSameDay(lastReset, today);
  }

  HabitModel _resetHabitForNewDay(HabitModel habit) {
    // Check if habit was completed yesterday to maintain streak
    final bool wasCompletedYesterday =
        habit.lastCompleted != null &&
        DateUtils.isYesterday(habit.lastCompleted!);

    // Reset streak if not completed yesterday
    int newStreak = habit.streakCount;
    if (!wasCompletedYesterday && habit.streakCount > 0) {
      newStreak = 0; // Reset streak for missed day
    }

    return habit.copyWith(
      isCompleteToday: false,
      goalCompletedCount: 0,
      streakCount: newStreak,
    );
  }
}
