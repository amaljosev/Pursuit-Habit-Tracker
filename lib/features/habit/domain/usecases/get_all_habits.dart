import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class GetAllHabitsUseCase implements UseCase<List<Habit>, NoParams> {
  final HabitRepository repository;

  GetAllHabitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Habit>>> call(NoParams params) {
    return repository.getAllHabits();
  }
}
