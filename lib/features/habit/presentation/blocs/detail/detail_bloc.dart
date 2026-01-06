import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/update_goal_count.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final GetHabitByIdUseCase getHabitByIdUseCase;
  final UpdateGoalCountUseCase updateGoalCountUseCase;
  DetailBloc({
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.getHabitByIdUseCase,
    required this.updateGoalCountUseCase,
  }) : super(HabitDetailInitial()) {
    on<UpdateHabitDetailEvent>(_onUpdateHabit);
    on<DeleteHabitDetailEvent>(_onDeleteHabit);
    on<GetHabitDetailByIdEvent>(_onGetHabitById);

    //Operations
    on<GoalCountUpdateDetailEvent>(_onCountIncrement);
  }
  // 🟠 UPDATE HABIT
  Future<void> _onUpdateHabit(
    UpdateHabitDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    // await Future.delayed(Duration(seconds: 2));
    final result = await updateHabitUseCase(event.habit);
    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (_) => emit(
        (state as HabitDetailLoaded).copyWith(
          habit: event.habit,
          goalCompletedCount: event.habit.goalCount,
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
      (_) => emit(HabitDetailOperationSuccess("Habit deleted successfully")),
    );
  }

  // 🔍 GET HABIT BY ID
  Future<void> _onGetHabitById(
    GetHabitDetailByIdEvent event,
    Emitter<DetailState> emit,
  ) async {
    emit(HabitDetailLoading());
    // await Future.delayed(Duration(seconds: 1));
    final result = await getHabitByIdUseCase(event.id);

    result.match((failure) => emit(HabitDetailError(failure.message)), (habit) {
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
    });
  }

  FutureOr<void> _onCountIncrement(
    GoalCountUpdateDetailEvent event,
    Emitter<DetailState> emit,
  ) async {
    final result = await updateGoalCountUseCase(
      UpdateGoalCountParams(id: event.id, value: event.value),
    );

    result.match(
      (failure) => emit(HabitDetailError(failure.message)),
      (_) => emit(
        (state as HabitDetailLoaded).copyWith(
          habit: event.habit,
          goalCompletedCount: event.value,
        ),
      ),
    );
  }
}
