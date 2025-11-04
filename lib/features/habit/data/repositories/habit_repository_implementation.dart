import 'dart:developer';

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
}
