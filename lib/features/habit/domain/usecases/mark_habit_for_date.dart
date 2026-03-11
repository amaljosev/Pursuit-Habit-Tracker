// domain/usecases/mark_habit_for_date_usecase.dart
import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class MarkHabitForDateParams {
  final String id;
  final DateTime date;
  final int count;
  final bool isCompleted;

  const MarkHabitForDateParams({
    required this.id,
    required this.date,
    required this.count,
    required this.isCompleted,
  });
}

class MarkHabitForDateUseCase {
  final HabitRepository repository;

  MarkHabitForDateUseCase(this.repository);

  Future<Either<Failure, Habit>> call(MarkHabitForDateParams params) {
    return repository.markHabitForDate(
      id: params.id,
      date: params.date,
      count: params.count,
      isCompleted: params.isCompleted,
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// domain/usecases/get_habits_for_date_usecase.dart

// Used by the Calendar screen to show what was due on a tapped day.

class GetHabitsForDateUseCase {
  final HabitRepository repository;

  GetHabitsForDateUseCase(this.repository);

  Future<Either<Failure, List<Habit>>> call(DateTime date) {
    return repository.getHabitsForDate(date);
  }
}