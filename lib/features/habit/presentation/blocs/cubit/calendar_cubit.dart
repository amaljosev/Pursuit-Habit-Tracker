import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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

  // ─── Helper ────────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ─── Month navigation ──────────────────────────────────────────────────────

  void goToPreviousMonth() {
    final current = state.focusedMonth;
    final prev = DateTime(current.year, current.month - 1, 1);
    emit(state.copyWith(focusedMonth: prev));
    loadMonthStatus(prev);
  }

  void goToNextMonth() {
    final current = state.focusedMonth;
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + 1, 1);
    if (next.isAfter(DateTime(now.year, now.month, 1))) return;
    emit(state.copyWith(focusedMonth: next));
    loadMonthStatus(next);
  }

  // ─── Month status loader ───────────────────────────────────────────────────

  Future<void> loadMonthStatus(DateTime month) async {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    final futures = List.generate(daysInMonth, (i) async {
      final date = DateTime(month.year, month.month, i + 1);
      if (date.isAfter(todayNorm)) return MapEntry(_dateKey(date), '');

      final result = await getHabitsForDateUseCase(date);
      return result.fold(
        (_) => MapEntry(_dateKey(date), ''),
        (habits) {
          if (habits.isEmpty) return MapEntry(_dateKey(date), '');
          final completed =
              habits.where((h) => h.isCompletedOnDate(date)).length;
          final String status;
          if (completed == habits.length) {
            status = 'done';
          } else if (completed > 0) {
            status = 'partial';
          } else if (date.isBefore(todayNorm)) {
            status = 'missed';
          } else {
            status = '';
          }
          return MapEntry(_dateKey(date), status);
        },
      );
    });

    final entries = await Future.wait(futures);
    final map = Map<String, String>.fromEntries(
      entries.where((e) => e.value.isNotEmpty),
    );
    emit(state.copyWith(monthDayStatus: map));
  }

  // ─── Date selection ────────────────────────────────────────────────────────

  Future<void> selectDate(DateTime date) async {
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day))) return;

    emit(
        state.copyWith(selectedDate: date, isLoadingDay: true, habitsForDate: []));

    final result = await getHabitsForDateUseCase(date);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingDay: false, error: failure.message)),
      (habits) {
        emit(state.copyWith(isLoadingDay: false, habitsForDate: habits));
        _updateDayStatus(date, habits);
      },
    );
  }

  // ─── Toggle habit on date ──────────────────────────────────────────────────

  Future<void> toggleHabitOnDate({
    required String habitId,
    required DateTime date,
    required bool markCompleted,
    required int count,
  }) async {
    final optimistic = state.habitsForDate.map((h) {
      if (h.id != habitId) return h;
      final dateKey = _dateKey(date);
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
    _updateDayStatus(date, optimistic);

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
        _updateDayStatus(date, confirmed);
      },
    );
  }

  // ─── Refresh date ──────────────────────────────────────────────────────────

  Future<void> refreshDate(DateTime date) async {
    emit(state.copyWith(isLoadingDay: true, habitsForDate: []));
    final result = await getHabitsForDateUseCase(date);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingDay: false, error: failure.message)),
      (habits) {
        emit(state.copyWith(isLoadingDay: false, habitsForDate: habits));
        _updateDayStatus(date, habits);
      },
    );
  }

  // ─── Keep dot in sync ──────────────────────────────────────────────────────

  void _updateDayStatus(DateTime date, List<Habit> habits) {
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final dateNorm = DateTime(date.year, date.month, date.day);

    final String status;
    if (habits.isEmpty) {
      status = '';
    } else {
      final completed =
          habits.where((h) => h.isCompletedOnDate(date)).length;
      if (completed == habits.length) {
        status = 'done';
      } else if (completed > 0) {
        status = 'partial';
      } else if (dateNorm.isBefore(todayNorm)) {
        status = 'missed';
      } else {
        status = '';
      }
    }

    final updated = Map<String, String>.from(state.monthDayStatus);
    if (status.isEmpty) {
      updated.remove(_dateKey(date));
    } else {
      updated[_dateKey(date)] = status;
    }
    emit(state.copyWith(monthDayStatus: updated));
  }

  void clearError() => emit(state.copyWith(error: null));
}