// presentation/blocs/calendar/calendar_state.dart
part of 'calendar_cubit.dart';

class CalendarState extends Equatable {
  /// The month currently rendered in the grid.
  final DateTime focusedMonth;

  /// The date the user tapped (null = nothing selected yet).
  final DateTime? selectedDate;

  /// Habits active on [selectedDate].
  final List<Habit> habitsForDate;

  final bool isLoadingDay;
  final String? error;

  const CalendarState({
    required this.focusedMonth,
    required this.selectedDate,
    required this.habitsForDate,
    required this.isLoadingDay,
    this.error,
  });

  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      focusedMonth: DateTime(now.year, now.month, 1),
      selectedDate: null,
      habitsForDate: [],
      isLoadingDay: false,
    );
  }

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
    List<Habit>? habitsForDate,
    bool? isLoadingDay,
    String? error,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      habitsForDate: habitsForDate ?? this.habitsForDate,
      isLoadingDay: isLoadingDay ?? this.isLoadingDay,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [focusedMonth, selectedDate, habitsForDate, isLoadingDay, error];
}