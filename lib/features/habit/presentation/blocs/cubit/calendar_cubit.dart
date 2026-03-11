import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/mark_habit_for_date.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final GetHabitsForDateUseCase getHabitsForDateUseCase;
  final MarkHabitForDateUseCase markHabitForDateUseCase;

  CalendarCubit({
    required this.getHabitsForDateUseCase,
    required this.markHabitForDateUseCase,
  }) : super(CalendarState.initial());

  // ─── Month navigation ──────────────────────────────────────────────────────

  void goToPreviousMonth() {
    final current = state.focusedMonth;
    emit(state.copyWith(focusedMonth: DateTime(current.year, current.month - 1, 1)));
  }

  void goToNextMonth() {
    final current = state.focusedMonth;
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + 1, 1);
    if (next.isAfter(DateTime(now.year, now.month, 1))) return;
    emit(state.copyWith(focusedMonth: next));
  }

  // ─── Date selection ────────────────────────────────────────────────────────

  Future<void> selectDate(DateTime date) async {
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day))) return;

    emit(state.copyWith(selectedDate: date, isLoadingDay: true, habitsForDate: []));

    final result = await getHabitsForDateUseCase(date);
    result.fold(
      (failure) => emit(state.copyWith(isLoadingDay: false, error: failure.message)),
      (habits) => emit(state.copyWith(isLoadingDay: false, habitsForDate: habits)),
    );
  }

  Future<void> toggleHabitOnDate({
    required String habitId,
    required DateTime date,
    required bool markCompleted,
    required int count,
  }) async {
    final optimistic = state.habitsForDate.map((h) {
      if (h.id != habitId) return h;
      final dateKey = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      final updatedDays = List<Map<String, dynamic>>.from(
        h.completedDays.map((e) => Map<String, dynamic>.from(e)),
      );
      final existing = updatedDays.indexWhere((e) => e['date'] == dateKey);
      final newEntry = {
        'date': dateKey,
        'count': count,
        'isCompleted': markCompleted,
      };
      if (existing >= 0) {
        updatedDays[existing] = newEntry;
      } else {
        updatedDays.add(newEntry);
      }
      return h.copyWith(completedDays: updatedDays);
    }).toList();

    emit(state.copyWith(habitsForDate: optimistic));

    // Persist to DB
    final result = await markHabitForDateUseCase(
      MarkHabitForDateParams(
        id: habitId,
        date: date,
        count: count,          
        isCompleted: markCompleted,
      ),
    );

    result.fold(
      (failure) {
        selectDate(date);
        emit(state.copyWith(error: failure.message));
      },
      (updatedHabit) {
        final confirmed = state.habitsForDate.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();
        emit(state.copyWith(habitsForDate: confirmed));
      },
    );
  }

  Future<void> refreshDate(DateTime date) async {
    final result = await getHabitsForDateUseCase(date);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (habits) => emit(state.copyWith(habitsForDate: habits)),
    );
  }

  void clearError() => emit(state.copyWith(error: null));
}