import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class UpdateHabitUseCase implements UseCase<void, Habit> {
  final HabitRepository repository;

  UpdateHabitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Habit habit) {
    return repository.updateHabit(habit);
  }
}
