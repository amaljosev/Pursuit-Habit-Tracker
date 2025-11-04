import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class InsertHabitUseCase implements UseCase<void, Habit> {
  final HabitRepository repository;

  InsertHabitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Habit habit) {
    return repository.insertHabit(habit);
  }
}
