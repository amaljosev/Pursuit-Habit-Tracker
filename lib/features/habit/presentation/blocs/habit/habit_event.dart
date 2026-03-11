// presentation/blocs/habit/habit_event.dart
part of 'habit_bloc.dart';

sealed class HabitEvent extends Equatable {
  const HabitEvent();
  @override
  List<Object> get props => [];
}

// ─── Form UI events (unchanged) ───────────────────────────────────────────────

final class AddHabitInitialEvent extends HabitEvent {
  const AddHabitInitialEvent();
}

final class CustomHabitInitialEvent extends HabitEvent {
  final LibraryModel customHabit;
  const CustomHabitInitialEvent({required this.customHabit});
  @override
  List<Object> get props => [customHabit];
}

final class UpdateHabitInitialEvent extends HabitEvent {
  final Habit habit;
  const UpdateHabitInitialEvent({required this.habit});
  @override
  List<Object> get props => [habit];
}

final class RenewalHabitInitialEvent extends HabitEvent {
  final Habit habit;
  const RenewalHabitInitialEvent({required this.habit});
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

// ─── Domain events ────────────────────────────────────────────────────────────

final class AddHabitEvent extends HabitEvent {
  final Habit habit;
  const AddHabitEvent(this.habit);
  @override
  List<Object> get props => [habit];
}

final class GetAllHabitsEvent extends HabitEvent {}

final class UpdateHabitEvent extends HabitEvent {
  final Habit habit;
  const UpdateHabitEvent(this.habit);
  @override
  List<Object> get props => [habit];
}

final class DeleteHabitEvent extends HabitEvent {
  final String id;
  const DeleteHabitEvent(this.id);
  @override
  List<Object> get props => [id];
}

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
  List<Object> get props => [id, value, habit];
}

class MarkHabitForDateEvent extends HabitEvent {
  final String habitId;
  final DateTime date;
  final int count;
  final bool isCompleted;

  const MarkHabitForDateEvent({
    required this.habitId,
    required this.date,
    required this.count,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [habitId, date, count, isCompleted];
}

class CancelAllHabitNotificationsEvent extends HabitEvent {
  final bool isActive;
  const CancelAllHabitNotificationsEvent(this.isActive);
  @override
  List<Object> get props => [isActive];
}