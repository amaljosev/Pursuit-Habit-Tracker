part of 'detail_bloc.dart';

sealed class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object> get props => [];
}

final class HabitDetailInitial extends DetailState {}

class HabitDetailLoading extends DetailState {}

class HabitDetailLoaded extends DetailState {
  final Habit habit;
  final int goalCompletedCount;

  const HabitDetailLoaded({
    required this.habit,
    required this.goalCompletedCount,
  });
  HabitDetailLoaded copyWith({Habit? habit, int? goalCompletedCount}) =>
      HabitDetailLoaded(
        habit: habit ?? this.habit,
        goalCompletedCount: goalCompletedCount ?? this.goalCompletedCount,
      );
  @override
  List<Object> get props => [habit, goalCompletedCount];
}

class HabitDetailError extends DetailState {
  final String message;
  const HabitDetailError(this.message);

  @override
  List<Object> get props => [message];
}

class HabitDetailOperationSuccess extends DetailState {
  final String message;
  const HabitDetailOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class HabitDetailCountUpdateSuccess extends DetailState {
  final Habit habit;
  final double updatedCount;
  const HabitDetailCountUpdateSuccess({
    required this.updatedCount,
    required this.habit,
  });
  @override
  List<Object> get props => [updatedCount, habit];
}
class HabitDetailUpdateSuccessState extends DetailState {
  final String message;
  const HabitDetailUpdateSuccessState(this.message);

  @override
  List<Object> get props => [message];
}
