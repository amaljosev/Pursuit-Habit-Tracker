import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/mark_habit_for_date.dart';
import 'package:pursuit/features/habit/domain/usecases/update_goal_count.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final GetHabitByIdUseCase getHabitByIdUseCase;
  final UpdateGoalCountUseCase updateGoalCountUseCase;
  final MarkHabitForDateUseCase markHabitForDateUseCase; 

  DetailBloc({
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.getHabitByIdUseCase,
    required this.updateGoalCountUseCase,
    required this.markHabitForDateUseCase, 
  }) : super(HabitDetailInitial()) {
    on<ResetHabitScreenEvent>((event, emit) => emit(HabitDetailInitial()));
    on<UpdateHabitDetailEvent>(_onUpdateHabit);
    on<DeleteHabitDetailEvent>(_onDeleteHabit);
    on<GetHabitDetailByIdEvent>(_onGetHabitById);
    on<GoalCountUpdateDetailEvent>(_onCountIncrement);
    on<MarkHabitForDateDetailEvent>(_onMarkHabitForDate); 
  }

  // 🟠 UPDATE HABIT
  Future<void> _onUpdateHabit(
    UpdateHabitDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    final result = await updateHabitUseCase(event.habit);
    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (_) => emit(
        (state as HabitDetailLoaded).copyWith(
          habit: event.habit,
          goalCompletedCount: event.habit.goalCompletedCount,
        ),
      ),
    );
  }

  // 🔴 DELETE HABIT
  Future<void> _onDeleteHabit(
    DeleteHabitDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    emit(HabitDetailLoading());
    final result = await deleteHabitUseCase(event.id);
    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (_) => emit(const HabitDetailOperationSuccess("Habit deleted successfully")),
    );
  }

  // 🔍 GET HABIT BY ID
  Future<void> _onGetHabitById(
    GetHabitDetailByIdEvent event,
    Emitter<DetailState> emit,
  ) async {
    emit(HabitDetailLoading());
    final result = await getHabitByIdUseCase(event.id);
    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (habit) {
        if (habit == null) {
          emit(const HabitDetailError("Habit not found"));
        } else {
          emit(
            HabitDetailLoaded(
              habit: habit,
              goalCompletedCount: habit.goalCompletedCount,
            ),
          );
        }
      },
    );
  }

  // ➕ GOAL COUNT UPDATE (today only)
  // Routes through markHabitForDateUseCase so completedDays + all
  // stats (streak, countThis*, etc.) are always recalculated in the repo.
  FutureOr<void> _onCountIncrement(
    GoalCountUpdateDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    // Optimistic update so +/- buttons feel instant
    if (state is HabitDetailLoaded) {
      emit(
        (state as HabitDetailLoaded).copyWith(
          goalCompletedCount: event.value,
        ),
      );
    }

    final isCompleted = event.value >= event.habit.goalCount;

    final result = await markHabitForDateUseCase(
      MarkHabitForDateParams(
        id: event.id,
        date: DateTime.now(),
        count: event.value,
        isCompleted: isCompleted,
      ),
    );

    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (updatedHabit) => emit(
        HabitDetailLoaded(
          habit: updatedHabit,
          goalCompletedCount: updatedHabit.goalCompletedCount,
        ),
      ),
    );
  }

  // 📅 MARK FOR ANY DATE (past or present — used by CalendarScreen)
  FutureOr<void> _onMarkHabitForDate(
    MarkHabitForDateDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    emit(HabitDetailLoading());

    final result = await markHabitForDateUseCase(
      MarkHabitForDateParams(
        id: event.habitId,
        date: event.date,
        count: event.count,
        isCompleted: event.isCompleted,
      ),
    );

    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (updatedHabit) => emit(
        HabitDetailLoaded(
          habit: updatedHabit,
          goalCompletedCount: updatedHabit.goalCompletedCount,
        ),
      ),
    );
  }
}