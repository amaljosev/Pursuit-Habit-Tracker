import 'dart:async';
import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/functions/math_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/core/usecases/usecase.dart';
import 'package:pursuit/core/utils/shared_prefs_utils.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_all_habit_notifications_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/mark_habit_for_date.dart';
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
  final MarkHabitForDateUseCase markHabitForDateUseCase;
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
    required this.markHabitForDateUseCase,
    required this.scheduleHabitNotificationUseCase,
    required this.cancelHabitNotificationUseCase,
    required this.cancelAllHabitNotificationsUseCase,
  }) : super(HabitInitial()) {
    // UI form events
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
    // Domain events
    on<AddHabitEvent>(_onInsertHabit);
    on<GetAllHabitsEvent>(_onGetAllHabits);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);

    // Tracking events
    on<GoalCountUpdateEvent>(_onCountIncrement);
    on<MarkHabitForDateEvent>(_onMarkHabitForDate);

    // Notification events
    on<CancelAllHabitNotificationsEvent>(_onCancelAllNotifications);
  }

  // ─── Form UI handlers (unchanged) ─────────────────────────────────────────

  void _onAddHabitInitialEvent(
    AddHabitInitialEvent e,
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
    CustomHabitInitialEvent e,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: getRandomInt(AppColors.lightColors.length - 1),
        icon: e.customHabit.icon,
        name: '',
        habitType: e.customHabit.cat,
        goalCount: e.customHabit.defaultGoal,
        goalValue: e.customHabit.measure, 
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
    UpdateHabitInitialEvent e,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: e.habit.color,
        icon: e.habit.icon,
        name: e.habit.name,
        habitType: e.habit.type,
        goalCount: e.habit.goalCount,
        goalValue: e.habit.goalValue,
        goalTime: e.habit.time,
        startDate: e.habit.startDate.toString(),
        endDate: e.habit.endDate != null
            ? HelperFunctions.formatDate(e.habit.endDate!)
            : '',
        isExpanded: e.habit.endDate != null,
        hasRemainder: e.habit.reminder != null && e.habit.reminder!.isNotEmpty,
        remainderTime: e.habit.reminder ?? '',
      ),
    );
  }

  void _onRenewalHabitInitialEvent(
    RenewalHabitInitialEvent e,
    Emitter<HabitState> emit,
  ) {
    emit(
      AddHabitInitial(
        color: e.habit.color,
        icon: e.habit.icon,
        name: e.habit.name,
        habitType: e.habit.type,
        goalCount: e.habit.goalCount,
        goalValue: e.habit.goalValue,
        goalTime: e.habit.time,
        startDate: e.habit.startDate.toString(),
        endDate: '',
        isExpanded: e.habit.endDate != null,
        hasRemainder: e.habit.reminder != null && e.habit.reminder!.isNotEmpty,
        remainderTime: e.habit.reminder ?? '',
      ),
    );
  }

  void _onHabitColorEvent(HabitColorEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(color: e.color));
  }

  void _onHabitNameEvent(HabitNameEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(name: e.name));
  }

  void _onHabitIconEvent(HabitIconEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(icon: e.icon));
  }

  void _onHabitTypeEvent(HabitTypeEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(habitType: e.habitType));
  }

  void _onHabitGoalCountEvent(HabitGoalCountEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(goalCount: e.goalCount));
  }

  void _onHabitGoalValueEvent(HabitGoalValueEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(goalValue: e.goalValue));
  }

  void _onHabitGoalTimeEvent(HabitGoalTimeEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(goalTime: e.goalTime));
  }

  void _onHabitEndDateEvent(HabitEndDateEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(endDate: e.endDate));
  }

  void _onHabitEndDateExpand(HabitEndDateExpand e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(isExpanded: e.isExpand));
  }

  void _onHabitRemainderEvent(HabitRemainderEvent e, Emitter<HabitState> emit) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(remainderTime: e.remainderTime));
  }

  void _onHabitRemainderToggleEvent(
    HabitRemainderToggleEvent e,
    Emitter<HabitState> emit,
  ) {
    if (state is AddHabitInitial)
      emit((state as AddHabitInitial).copyWith(hasRemainder: e.hasRemainder));
  }

  // ─── INSERT ────────────────────────────────────────────────────────────────

  Future<void> _onInsertHabit(
    AddHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final result = await insertHabitUseCase(event.habit);
      await result.match((failure) async => emit(HabitError(failure.message)), (
        _,
      ) async {
        if (event.habit.reminder != null && event.habit.reminder!.isNotEmpty) {
          final time = HelperFunctions.parse12HourTime(event.habit.reminder!);
          if (time != null && time.isAfter(DateTime.now())) {
            await scheduleHabitNotificationUseCase(
              habitId: event.habit.id.hashCode,
              habitName: event.habit.name,
              reminderTime: time,
            );
          }
        }
        emit(const HabitOperationSuccess("Habit inserted successfully"));
      });
    } catch (e, s) {
      log('InsertHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // ─── GET ALL ───────────────────────────────────────────────────────────────

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

  // ─── UPDATE ────────────────────────────────────────────────────────────────

  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final result = await updateHabitUseCase(event.habit);
      await result.match((failure) async => emit(HabitError(failure.message)), (
        _,
      ) async {
        final notificationId = event.habit.id.hashCode;
        final isCompletedToday = event.habit.isCompleteToday;

        if (isCompletedToday &&
            event.habit.reminder != null &&
            event.habit.reminder!.isNotEmpty) {
          final time = HelperFunctions.parse12HourTime(event.habit.reminder!);
          if (time != null && _isHourMinuteAfterNow(time)) {
            await SharedPrefsUtils.addSkippedReminder(event.habit.id);
          }
          await cancelHabitNotificationUseCase(notificationId);
        } else if (event.habit.reminder != null &&
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
        emit(const HabitUpdateSuccessState("Habit updated successfully"));
      });
    } catch (e, s) {
      log('UpdateHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────

  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      await cancelHabitNotificationUseCase(event.id.hashCode);
      final result = await deleteHabitUseCase(event.id);
      result.match(
        (failure) => emit(HabitError(failure.message)),
        (_) => emit(const HabitOperationSuccess("Habit deleted successfully")),
      );
    } catch (e, s) {
      log('DeleteHabit error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // ─── GOAL COUNT (today only, backward compat) ──────────────────────────────

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

  // ─── MARK FOR DATE (new — any date) ───────────────────────────────────────

  Future<void> _onMarkHabitForDate(
    MarkHabitForDateEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(HabitLoading());
      final result = await markHabitForDateUseCase(
        MarkHabitForDateParams(
          id: event.habitId,
          date: event.date,
          count: event.count,
          isCompleted: event.isCompleted,
        ),
      );
      result.match(
        (failure) => emit(HabitError(failure.message)),
        (updatedHabit) =>
            emit(HabitMarkedForDate(habit: updatedHabit, date: event.date)),
      );
    } catch (e, s) {
      log('MarkHabitForDate error: $e\n$s');
      emit(HabitError(e.toString()));
    }
  }

  // ─── CANCEL NOTIFICATIONS ──────────────────────────────────────────────────

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

  // ─── Reschedule skipped reminders (called externally on app resume) ─────────

  Future<void> rescheduleSkippedReminders() async {
    final skippedIds = await SharedPrefsUtils.getSkippedReminders();
    if (skippedIds.isEmpty) return;

    for (final habitId in skippedIds) {
      final result = await getHabitByIdUseCase(habitId);
      await result.fold((fail) async => log(fail.toString()), (habit) async {
        if (habit == null || habit.reminder == null || habit.reminder!.isEmpty)
          return;
        final time = HelperFunctions.parse12HourTime(habit.reminder!);
        if (time == null) return;
        await scheduleHabitNotificationUseCase(
          habitId: habit.id.hashCode,
          habitName: habit.name,
          reminderTime: time,
        );
      });
    }
    await SharedPrefsUtils.clearSkippedReminders();
  }

  bool _isHourMinuteAfterNow(DateTime input) {
    final now = DateTime.now();
    if (input.hour != now.hour) return input.hour > now.hour;
    return input.minute > now.minute;
  }
}
