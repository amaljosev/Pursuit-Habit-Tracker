part of 'detail_bloc.dart';

sealed class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object> get props => [];
}


/// 🔍 Get specific habit by ID
final class GetHabitDetailByIdEvent extends DetailEvent {
  final String id;
  const GetHabitDetailByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// 🟠 Update habit
final class UpdateHabitDetailEvent extends DetailEvent {
  final Habit habit;
  const UpdateHabitDetailEvent(this.habit);

  @override
  List<Object> get props => [habit];
}

/// 🔴 Delete habit
final class DeleteHabitDetailEvent extends DetailEvent {
  final String id;
  const DeleteHabitDetailEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GoalCountUpdateDetailEvent extends DetailEvent {
  final String id;
  final int value;
  final Habit habit;
  const GoalCountUpdateDetailEvent({
    required this.id,
    required this.value,
    required this.habit,
  });

  @override
  List<Object> get props => [id, value, habit];
}
