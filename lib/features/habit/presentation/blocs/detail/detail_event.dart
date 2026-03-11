part of 'detail_bloc.dart';

sealed class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object> get props => [];
}

final class ResetHabitScreenEvent extends DetailEvent {}

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

/// ➕ Update today's goal count
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

/// 📅 NEW — mark any date (past or present) as completed/incomplete.
/// Used by CalendarScreen to edit historical completion.
class MarkHabitForDateDetailEvent extends DetailEvent {
  final String habitId;
  final DateTime date;
  final int count;
  final bool isCompleted;

  const MarkHabitForDateDetailEvent({
    required this.habitId,
    required this.date,
    required this.count,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [habitId, date, count, isCompleted];
}