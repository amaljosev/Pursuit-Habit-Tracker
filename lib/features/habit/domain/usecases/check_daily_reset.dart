import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import '../repositories/habit_repository.dart';

class CheckDailyResetUseCase {
  final HabitRepository repository;

  CheckDailyResetUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.checkAndPerformDailyReset();
  }
}