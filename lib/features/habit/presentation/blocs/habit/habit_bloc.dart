import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/functions/math_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_all_habit_notifications_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/check_daily_reset.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_all_habits.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/insert_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/schedule_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/update_goal_count.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_library_screen.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final InsertHabitUseCase insertHabitUseCase;
  final GetAllHabitsUseCase getAllHabitsUseCase;
  final UpdateHabitUseCase updateHabitUseCase;
  final DeleteHabitUseCase deleteHabitUseCase;
  final GetHabitByIdUseCase getHabitByIdUseCase;
  final UpdateGoalCountUseCase updateGoalCountUseCase;
  final CheckDailyResetUseCase checkDailyResetUseCase;
  final ScheduleHabitNotificationUseCase scheduleHabitNotificationUseCase;
  final CancelHabitNotificationUseCase cancelHabitNotificationUseCase;
  final CancelAllHabitNotificationsUseCase cancelAllHabitNotificationsUseCase;

  HabitBloc({
    required this.insertHabitUseCase,
    required this.getAllHabitsUseCase,
    required this.updateHabitUseCase,
    required this.deleteHabitUseCase,
    required this.getHabitByIdUseCase,
    required this.updateGoalCountUseCase,
    required this.checkDailyResetUseCase,
    required this.scheduleHabitNotificationUseCase,
    required this.cancelHabitNotificationUseCase,
    required this.cancelAllHabitNotificationsUseCase,
  }) : super(HabitInitial()) {
    // UI update events - only handle when state is AddHabitInitial
    on<AddHabitInitialEvent>(_onAddHabitInitialEvent);
    on<CustomHabitInitialEvent>(_onCustomHabitInitialEvent);
    on<UpdateHabitInitialEvent>(_onUpdateHabitInitialEvent);
    on<RenewalHabitInitialEvent>(_onRenewalHabitInitialEvent);
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
    // on<GetHabitByIdEvent>(_onGetHabitById);

    //Operations
    on<GoalCountUpdateEvent>(_onCountIncrement);

    // Add daily reset event handler
    on<CheckDailyResetEvent>(_onCheckDailyReset);
    on<CancelAllHabitNotificationsEvent>(_onCancelAllNotifications);
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
        goalCount: 1,
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

  void _onCustomHabitInitialEvent(
    CustomHabitInitialEvent event,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: getRandomInt(AppColors.lightColors.length - 1),
        icon: event.customHabit.icon,
        name: '',
        habitType:event.customHabit.cat,
        goalCount: 1,
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

  void _onUpdateHabitInitialEvent(
    UpdateHabitInitialEvent event,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: event.habit.color,
        icon: event.habit.icon,
        name: event.habit.name,
        habitType: event.habit.type,
        goalCount: event.habit.goalCount,
        goalValue: event.habit.goalValue,
        goalTime: event.habit.time,
        startDate: event.habit.startDate.toString(),
        endDate: event.habit.endDate != null
            ? HelperFunctions.formatDate(event.habit.endDate!)
            : '',
        isExpanded: event.habit.endDate != null,
        hasRemainder:
            event.habit.reminder != null && event.habit.reminder!.isNotEmpty,
        remainderTime: event.habit.reminder ?? '',
      ),
    );
  }

  void _onRenewalHabitInitialEvent(
    RenewalHabitInitialEvent event,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: event.habit.color,
        icon: event.habit.icon,
        name: event.habit.name,
        habitType: event.habit.type,
        goalCount: event.habit.goalCount,
        goalValue: event.habit.goalValue,
        goalTime: event.habit.time,
        startDate: event.habit.startDate.toString(),
        endDate: '',
        isExpanded: event.habit.endDate != null,
        hasRemainder:
            event.habit.reminder != null && event.habit.reminder!.isNotEmpty,
        remainderTime: event.habit.reminder ?? '',
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

      await result.match(
        (failure) async {
          emit(HabitError(failure.message));
          log(failure.toString());
        },
        (_) async {
          // ✅ Schedule notification ONLY after success
          if (event.habit.reminder != null &&
              event.habit.reminder!.isNotEmpty) {
            final time = HelperFunctions.parse12HourTime(event.habit.reminder!);
            // log(time.toString());
            if (time != null && time.isAfter(DateTime.now())) {
              await scheduleHabitNotificationUseCase(
                habitId: event.habit.id.hashCode,
                habitName: event.habit.name,
                reminderTime: time,
              );
            }
          }

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
    try {
      emit(HabitLoading());

      final result = await updateHabitUseCase(event.habit);

      await result.match(
        (failure) async {
          emit(HabitError(failure.message));
          log(failure.toString());
        },
        (_) async {
          final int notificationId = event.habit.id.hashCode;

          // 🛑 Cancel previous notification first (ALWAYS SAFE)
          await cancelHabitNotificationUseCase(notificationId);

          // ✅ Re-schedule only if reminder exists
          if (event.habit.reminder != null &&
              event.habit.reminder!.isNotEmpty) {
            final time = HelperFunctions.parse12HourTime(event.habit.reminder!);

            if (time != null) {
              await scheduleHabitNotificationUseCase(
                habitId: notificationId,
                habitName: event.habit.name,
                reminderTime: time,
              );
            }
          }

          emit(HabitUpdateSuccessState("Habit updated successfully"));
        },
      );
    } catch (e, s) {
      log('UpdateHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // 🔴 DELETE HABIT
  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());

      final int notificationId = event.id.hashCode;

      // 🛑 Cancel notification BEFORE deleting habit
      await cancelHabitNotificationUseCase(notificationId);

      final result = await deleteHabitUseCase(event.id);

      result.match(
        (failure) {
          emit(HabitError(failure.message));
        },
        (_) {
          emit(HabitOperationSuccess("Habit deleted successfully"));
        },
      );
    } catch (e, s) {
      log('DeleteHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // // 🔍 GET HABIT BY ID
  // Future<void> _onGetHabitById(
  //   GetHabitByIdEvent event,
  //   Emitter<HabitState> emit,
  // ) async {
  //   emit(HabitLoading());
  //   // await Future.delayed(Duration(seconds: 1));
  //   final result = await getHabitByIdUseCase(event.id);

  //   result.match((failure) => emit(HabitError(failure.message)), (habit) {
  //     if (habit == null) {
  //       emit(const HabitError("Habit not found"));
  //     } else {
  //       emit(
  //         HabitDetailLoaded(
  //           habit: habit,
  //           goalCompletedCount: habit.goalCompletedCount,
  //         ),
  //       );
  //     }
  //   });
  // }

  FutureOr<void> _onCountIncrement(
    GoalCountUpdateEvent event,
    Emitter<HabitState> emit,
  ) async {
    final result = await updateGoalCountUseCase(
      UpdateGoalCountParams(id: event.id, value: event.value),
    );

    result.match(
      (failure) => emit(HabitError(failure.message)),
      (_) => emit(
        HabitCountUpdateSuccess(updatedCount: event.value, habit: event.habit),
      ),
    );
  }

  Future<void> _onCheckDailyReset(
    CheckDailyResetEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final result = await checkDailyResetUseCase();

      result.fold(
        (failure) {
          emit(HabitError(failure.message));
          log(failure.toString());
          log('❌ Daily reset failed: ${failure.message}');
        },
        (_) {
          emit(HabitDailyResetCompleted());
          log('✅ Daily reset completed successfully');
        },
      );
    } catch (e, s) {
      log('CheckDailyReset error: $e\n$s');
      emit(HabitError('Daily reset failed: $e'));
    }
  }

  Future<void> _onCancelAllNotifications(
    CancelAllHabitNotificationsEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());

      await cancelAllHabitNotificationsUseCase();

      emit(CancelAllNotifications(event.isActive));
    } catch (e, s) {
      log('CancelAllNotifications error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }
}
