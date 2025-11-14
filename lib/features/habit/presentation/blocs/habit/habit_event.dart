part of 'habit_bloc.dart';

sealed class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object> get props => [];
}

final class AddHabitInitialEvent extends HabitEvent {
  const AddHabitInitialEvent();
  @override
  List<Object> get props => [];
}

final class UpdateHabitInitialEvent extends HabitEvent {
  final Habit habit;
  const UpdateHabitInitialEvent({required this.habit});
  @override
  List<Object> get props => [habit];
}

final class HabitIconEvent extends HabitEvent {
  final int icon;

  const HabitIconEvent({required this.icon});
  @override
  List<Object> get props => [icon];
}

final class HabitNameEvent extends HabitEvent {
  final String name;

  const HabitNameEvent({required this.name});
  @override
  List<Object> get props => [name];
}

final class HabitColorEvent extends HabitEvent {
  final int color;

  const HabitColorEvent({required this.color});
  @override
  List<Object> get props => [color];
}

final class HabitTypeEvent extends HabitEvent {
  final int habitType;

  const HabitTypeEvent({required this.habitType});
  @override
  List<Object> get props => [habitType];
}

final class HabitGoalCountEvent extends HabitEvent {
  final int goalCount;

  const HabitGoalCountEvent({required this.goalCount});
  @override
  List<Object> get props => [goalCount];
}

final class HabitGoalValueEvent extends HabitEvent {
  final int goalValue;

  const HabitGoalValueEvent({required this.goalValue});
  @override
  List<Object> get props => [goalValue];
}

final class HabitGoalTimeEvent extends HabitEvent {
  final int goalTime;

  const HabitGoalTimeEvent({required this.goalTime});
  @override
  List<Object> get props => [goalTime];
}

final class HabitEndDateEvent extends HabitEvent {
  final String endDate;

  const HabitEndDateEvent({required this.endDate});
  @override
  List<Object> get props => [endDate];
}

final class HabitEndDateExpand extends HabitEvent {
  final bool isExpand;

  const HabitEndDateExpand({required this.isExpand});
  @override
  List<Object> get props => [isExpand];
}

final class HabitRemainderToggleEvent extends HabitEvent {
  final bool hasRemainder;

  const HabitRemainderToggleEvent({required this.hasRemainder});
  @override
  List<Object> get props => [hasRemainder];
}

final class HabitRemainderEvent extends HabitEvent {
  final String remainderTime;

  const HabitRemainderEvent({required this.remainderTime});
  @override
  List<Object> get props => [remainderTime];
}

/// 🟢 Add new habit
final class AddHabitEvent extends HabitEvent {
  final Habit habit;
  const AddHabitEvent(this.habit);

  @override
  List<Object> get props => [habit];
}

/// 🔵 Get all habits
final class GetAllHabitsEvent extends HabitEvent {}

/// 🟠 Update habit
final class UpdateHabitEvent extends HabitEvent {
  final Habit habit;
  const UpdateHabitEvent(this.habit);

  @override
  List<Object> get props => [habit];
}

/// 🔴 Delete habit
final class DeleteHabitEvent extends HabitEvent {
  final String id;
  const DeleteHabitEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// 🔍 Get specific habit by ID
final class GetHabitByIdEvent extends HabitEvent {
  final String id;
  const GetHabitByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GoalCountUpdateEvent extends HabitEvent {
  final String id;
  final int value;
  final Habit habit;
  const GoalCountUpdateEvent({
    required this.id,
    required this.value,
    required this.habit,
  });

  @override
  List<Object> get props => [id, value,habit];
}

class CheckDailyResetEvent extends HabitEvent {}
