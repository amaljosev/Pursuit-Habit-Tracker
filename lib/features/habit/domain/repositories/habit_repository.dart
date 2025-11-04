import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<Either<Failure, void>> insertHabit(Habit habit);
  Future<Either<Failure, List<Habit>>> getAllHabits();
  Future<Either<Failure, void>> deleteHabit(String id);
  Future<Either<Failure, void>> updateHabit(Habit habit);
  Future<Either<Failure, Habit?>> getHabitById(String id);
}
