import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:pursuit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:pursuit/features/habit/data/repositories/habit_repository_implementation.dart';
import 'package:pursuit/features/habit/data/repositories/local_notification_repository_impl.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';
import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_all_habit_notifications_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/cancel_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/mark_habit_for_date.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/insert_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_all_habits.dart';
import 'package:pursuit/features/habit/domain/usecases/schedule_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/update_goal_count.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/cubit/calendar_cubit.dart';
import 'package:pursuit/features/habit/presentation/blocs/detail/detail_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // ─── Notification ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRepository>(
    () => LocalNotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ScheduleHabitNotificationUseCase(sl()));
  sl.registerLazySingleton(() => CancelHabitNotificationUseCase(sl()));
  sl.registerLazySingleton(() => CancelAllHabitNotificationsUseCase(sl()));

  // ─── Data source ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(),
  );

  // ─── Repository ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl()),
  );

  // ─── Use cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => InsertHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetAllHabitsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHabitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGoalCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkHabitForDateUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitsForDateUseCase(sl()));

  // ─── Blocs / Cubits ────────────────────────────────────────────────────────
  sl.registerFactory(
    () => HabitBloc(
      insertHabitUseCase: sl(),
      getAllHabitsUseCase: sl(),
      updateHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
      getHabitByIdUseCase: sl(),
      updateGoalCountUseCase: sl(),
      markHabitForDateUseCase: sl(), 
      scheduleHabitNotificationUseCase: sl(),
      cancelHabitNotificationUseCase: sl(),
      cancelAllHabitNotificationsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DetailBloc(
      updateHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
      getHabitByIdUseCase: sl(),
      updateGoalCountUseCase: sl(),
      markHabitForDateUseCase: sl(),
    ),
  );

  // CalendarCubit
  sl.registerFactory(
    () => CalendarCubit(
      getHabitsForDateUseCase: sl(),
      markHabitForDateUseCase: sl(),
    ),
  );
}
