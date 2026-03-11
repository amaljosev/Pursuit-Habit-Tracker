import 'dart:developer';
import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:pursuit/features/habit/data/models/habit_model.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  // ─── Helpers ───────────────────────────────────────────────────────────────

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseKey(String key) => DateTime.parse(key);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ─── Recalculate all derived statistics ────────────────────────────────────

  HabitModel _recalculateStats(HabitModel habit) {
    final now = DateTime.now();
    final today = _dateOnly(now);

    // 1. Collect all completed dates (sorted ascending)
    final completedDates =
        habit.completedDays
            .where((e) => e['isCompleted'] == true)
            .map((e) => _dateOnly(_parseKey(e['date'] as String)))
            .toSet()
            .toList()
          ..sort();

    // 2. Current streak – walk backwards from today
    int streak = 0;
    DateTime cursor = today;
    while (true) {
      final found = completedDates.any((d) => _isSameDay(d, cursor));
      if (!found) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // 3. Best streak – sliding window
    int best = streak;
    if (completedDates.isNotEmpty) {
      int run = 1;
      int maxRun = 1;
      for (int i = 1; i < completedDates.length; i++) {
        final diff = completedDates[i].difference(completedDates[i - 1]).inDays;
        if (diff == 1) {
          run++;
          if (run > maxRun) maxRun = run;
        } else {
          run = 1;
        }
      }
      best = maxRun > best ? maxRun : best;
    }

    // 4. Period counts
    final thisWeekStart = today.subtract(Duration(days: today.weekday % 7));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));

    final thisYearStart = DateTime(now.year, 1, 1);
    final lastYearStart = DateTime(now.year - 1, 1, 1);
    final lastYearEnd = DateTime(now.year - 1, 12, 31);

    int countThisWeek = 0, countLastWeek = 0;
    int countThisMonth = 0, countLastMonth = 0;
    int countThisYear = 0, countLastYear = 0;

    for (final d in completedDates) {
      if (!d.isBefore(thisWeekStart) && !d.isAfter(today)) countThisWeek++;
      if (!d.isBefore(lastWeekStart) && !d.isAfter(lastWeekEnd))
        countLastWeek++;
      if (!d.isBefore(thisMonthStart) && !d.isAfter(today)) countThisMonth++;
      if (!d.isBefore(lastMonthStart) && !d.isAfter(lastMonthEnd))
        countLastMonth++;
      if (!d.isBefore(thisYearStart) && !d.isAfter(today)) countThisYear++;
      if (!d.isBefore(lastYearStart) && !d.isAfter(lastYearEnd))
        countLastYear++;
    }

    return habit.copyWith(
      streakCount: streak,
      bestStreak: best,
      countThisWeek: countThisWeek,
      countLastWeek: countLastWeek,
      countThisMonth: countThisMonth,
      countLastMonth: countLastMonth,
      countThisYear: countThisYear,
      countLastYear: countLastYear,
    );
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> insertHabit(Habit habit) async {
    try {
      await localDataSource.insertHabit(HabitModel.fromEntity(habit));
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
      return Right(models.map((m) => m.toEntity()).toList());
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
      await localDataSource.updateHabit(HabitModel.fromEntity(habit));
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

  // ─── updateGoalCount (kept for GoalCountUpdateEvent compatibility) ──────────

  /// Updates today's count on the completedDays list.
  /// Marks isCompleted=true when count reaches goalCount.
  @override
  Future<Either<Failure, void>> updateGoalCount({
    required String id,
    required int value,
  }) async {
    try {
      final model = await localDataSource.getHabitById(id);
      if (model == null) {
        return Left(DatabaseFailure(message: 'Habit not found: $id'));
      }
      final isCompleted = value >= model.goalCount;
      await localDataSource.markHabitForDate(
        habitId: id,
        date: DateTime.now(),
        count: value,
        isCompleted: isCompleted,
      );
      final updated = await localDataSource.getHabitById(id);
      if (updated != null) {
        final recalculated = _recalculateStats(updated);
        await localDataSource.updateHabit(recalculated);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update goal count: $e'));
    }
  }

  // ─── markHabitForDate ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Habit>> markHabitForDate({
    required String id,
    required DateTime date,
    required int count,
    required bool isCompleted,
  }) async {
    try {
      // 1. Write the completion record
      await localDataSource.markHabitForDate(
        habitId: id,
        date: date,
        count: count,
        isCompleted: isCompleted,
      );

      // 2. Reload then recalculate all stats
      final reloaded = await localDataSource.getHabitById(id);
      if (reloaded == null) {
        return Left(
          DatabaseFailure(message: 'Habit not found after mark: $id'),
        );
      }

      final recalculated = _recalculateStats(reloaded);
      await localDataSource.updateHabit(recalculated);

      log('✅ markHabitForDate done: $id on ${_dateKey(date)}');
      return Right(recalculated.toEntity());
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to mark habit for date: $e'),
      );
    }
  }

  // ─── getHabitsForDate ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Habit>>> getHabitsForDate(DateTime date) async {
    try {
      final models = await localDataSource.getAllHabits();
      final dateOnly = _dateOnly(date);

      final active = models
          .where((m) {
            final start = _dateOnly(m.startDate);
            if (start.isAfter(dateOnly)) return false;
            if (m.endDate != null) {
              final end = _dateOnly(m.endDate!);
              if (end.isBefore(dateOnly)) return false;
            }
            return true;
          })
          .map((m) => m.toEntity())
          .toList();

      return Right(active);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to get habits for date: $e'),
      );
    }
  }
}
