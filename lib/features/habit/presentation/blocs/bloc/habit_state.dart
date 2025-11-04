part of 'habit_bloc.dart';

sealed class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object> get props => [];
}
final class HabitInitial extends HabitState{}
final class AddHabitInitial extends HabitState {
  final int icon;
  final int color;
  final String name;
  final int habitType;
  final int goalCount;
  final int goalValue;
  final int goalTime;
  final String startDate;
  final String endDate;
  final bool isExpanded;
  final String remainderTime;
  final bool hasRemainder;

  const AddHabitInitial({
    required this.icon,
    required this.color,
    required this.name,
    required this.habitType,
    required this.goalCount,
    required this.goalValue,
    required this.goalTime,
    required this.startDate,
    required this.endDate,
    required this.isExpanded,
    required this.remainderTime,
    required this.hasRemainder,
  });
  AddHabitInitial copyWith({
    int? icon,
    int? color,
    String? name,
    int? habitType,
    int? goalCount,
    int? goalValue,
    int? goalTime,
    String? startDate,
    String? endDate,
    bool? isExpanded,
    bool? hasRemainder,
    String? remainderTime,
  }) {
    return AddHabitInitial(
      icon: icon ?? this.icon,
      color: color ?? this.color,
      name: name ?? this.name,
      habitType: habitType ?? this.habitType,
      goalCount: goalCount ?? this.goalCount,
      goalValue: goalValue ?? this.goalValue,
      goalTime: goalTime ?? this.goalTime,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isExpanded: isExpanded ?? this.isExpanded,
      hasRemainder: hasRemainder ?? this.hasRemainder,
      remainderTime: remainderTime ?? this.remainderTime,
    );
  }

  @override
  List<Object> get props => [
    icon,
    color,
    name,
    habitType,
    goalCount,
    goalValue,
    goalTime,
    startDate,
    endDate,
    isExpanded,
    hasRemainder,
    remainderTime,
  ];
}
class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  const HabitLoaded(this.habits);

  @override
  List<Object> get props => [habits];
}

class HabitOperationSuccess extends HabitState {
  final String message;
  const HabitOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class HabitError extends HabitState {
  final String message;
  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}

class HabitDetailLoaded extends HabitState {
  final Habit habit;
  const HabitDetailLoaded(this.habit);

  @override
  List<Object> get props => [habit];
}