import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class GetHabitByIdUseCase implements UseCase<Habit?, String> {
  final HabitRepository repository;

  GetHabitByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Habit?>> call(String id) {
    return repository.getHabitById(id);
  }
}
