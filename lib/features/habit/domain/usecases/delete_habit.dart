import 'package:fpdart/fpdart.dart';
import 'package:pursuit/core/error/failures.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';

class DeleteHabitUseCase implements UseCase<void, String> {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteHabit(id);
  }
}
