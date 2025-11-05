import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class UpdateGoalCountUseCase implements UseCase<void, UpdateGoalCountParams> {
  final HabitRepository repository;

  UpdateGoalCountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateGoalCountParams params) {
    return repository.updateGoalCount(
      id: params.id,
      value: params.value,
    );
  }
}

class UpdateGoalCountParams {
  final String id;
  final int value;

  UpdateGoalCountParams({required this.id, required this.value});
}
