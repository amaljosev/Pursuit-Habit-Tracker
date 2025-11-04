import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/functions/math_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_all_habits.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/insert_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final InsertHabitUseCase insertHabitUseCase;
  final GetAllHabitsUseCase getAllHabitsUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final GetHabitByIdUseCase getHabitByIdUseCase;

  HabitBloc({
    required this.insertHabitUseCase,
    required this.getAllHabitsUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.getHabitByIdUseCase,
  }) : super(HabitInitial()) {
    // UI update events - only handle when state is AddHabitInitial
    on<AddHabitInitialEvent>(_onAddHabitInitialEvent);
    on<HabitColorEvent>(_onHabitColorEvent);
    on<HabitNameEvent>(_onHabitNameEvent);
    on<HabitIconEvent>(_onHabitIconEvent);
    on<HabitTypeEvent>(_onHabitTypeEvent);
    on<HabitGoalCountEvent>(_onHabitGoalCountEvent);
    on<HabitGoalValueEvent>(_onHabitGoalValueEvent);
    on<HabitGoalTimeEvent>(_onHabitGoalTimeEvent);
    on<HabitEndDateEvent>(_onHabitEndDateEvent);
    on<HabitEndDateExpand>(_onHabitEndDateExpand);
    on<HabitRemainderEvent>(_onHabitRemainderEvent);
    on<HabitRemainderToggleEvent>(_onHabitRemainderToggleEvent);

    // Domain layer events
    on<AddHabitEvent>(_onInsertHabit);
    on<GetAllHabitsEvent>(_onGetAllHabits);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<GetHabitByIdEvent>(_onGetHabitById);
  }

  void _onAddHabitInitialEvent(
    AddHabitInitialEvent event,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: getRandomInt(AppColors.lightColors.length - 1),
        icon: getRandomInt(HabitIcons.emojis.length - 1),
        name: '',
        habitType: 0,
        goalCount: 10,
        goalValue: 0,
        goalTime: 0,
        startDate: DateTime.now().toIso8601String(),
        endDate: '',
        isExpanded: false,
        hasRemainder: false,
        remainderTime: '',
      ),
    );
  }

  // UI Event Handlers - only process if current state is AddHabitInitial
  void _onHabitColorEvent(HabitColorEvent event, Emitter<HabitState> emit) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(color: event.color));
    }
  }

  void _onHabitNameEvent(HabitNameEvent event, Emitter<HabitState> emit) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(name: event.name));
    }
  }

  void _onHabitIconEvent(HabitIconEvent event, Emitter<HabitState> emit) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(icon: event.icon));
    }
  }

  void _onHabitTypeEvent(HabitTypeEvent event, Emitter<HabitState> emit) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(habitType: event.habitType));
    }
  }

  void _onHabitGoalCountEvent(
    HabitGoalCountEvent event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(goalCount: event.goalCount));
    }
  }

  void _onHabitGoalValueEvent(
    HabitGoalValueEvent event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(goalValue: event.goalValue));
    }
  }

  void _onHabitGoalTimeEvent(
    HabitGoalTimeEvent event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(goalTime: event.goalTime));
    }
  }

  void _onHabitEndDateEvent(HabitEndDateEvent event, Emitter<HabitState> emit) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(endDate: event.endDate));
    }
  }

  void _onHabitEndDateExpand(
    HabitEndDateExpand event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit((state as AddHabitInitial).copyWith(isExpanded: event.isExpand));
    }
  }

  void _onHabitRemainderEvent(
    HabitRemainderEvent event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit(
        (state as AddHabitInitial).copyWith(remainderTime: event.remainderTime),
      );
    }
  }

  void _onHabitRemainderToggleEvent(
    HabitRemainderToggleEvent event,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial) {
      emit(
        (state as AddHabitInitial).copyWith(hasRemainder: event.hasRemainder),
      );
    }
  }

  // 🟢 INSERT HABIT
  Future<void> _onInsertHabit(
    AddHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final result = await insertHabitUseCase(event.habit);

      result.match(
        (failure) {
          emit(HabitError(failure.message));
        },
        (_) {
          emit(HabitOperationSuccess("Habit inserted successfully"));
        },
      );
    } catch (e, s) {
      log('InsertHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // 🔵 GET ALL HABITS
  Future<void> _onGetAllHabits(
    GetAllHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(HabitLoading());
    final result = await getAllHabitsUseCase(NoParams());

    result.match(
      (failure) => emit(HabitError(failure.message)),
      (habits) => emit(HabitLoaded(habits)),
    );
  }

  // 🟠 UPDATE HABIT
  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(HabitLoading());
    final result = await updateHabitUseCase(event.habit);
    result.match(
      (failure) => emit(HabitError(failure.message)),
      (_) => emit(HabitOperationSuccess("Habit updated successfully")),
    );
  }

  // 🔴 DELETE HABIT
  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(HabitLoading());
    
    final result = await deleteHabitUseCase(event.id);
    result.match(
      (failure) => emit(HabitError(failure.message)),
      (_) => emit(HabitOperationSuccess("Habit deleted successfully")),
    );
  }

  // 🔍 GET HABIT BY ID
  Future<void> _onGetHabitById(
    GetHabitByIdEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(HabitLoading());
    final result = await getHabitByIdUseCase(event.id);

    result.match((failure) => emit(HabitError(failure.message)), (habit) {
      if (habit == null) {
        emit(const HabitError("Habit not found"));
      } else {
        emit(HabitDetailLoaded(habit));
      }
    });
  }
}
