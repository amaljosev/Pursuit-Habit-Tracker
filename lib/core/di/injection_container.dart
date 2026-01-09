import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:pursuit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:pursuit/features/habit/data/repositories/habit_repository_implementation.dart';
import 'package:pursuit/features/habit/data/repositories/local_notification_repository_impl.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';
import 'package:pursuit/features/habit/domain/repositories/notification_repository.dart';
import 'package:pursuit/features/habit/domain/usecases/check_daily_reset.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/insert_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_all_habits.dart';
import 'package:pursuit/features/habit/domain/usecases/schedule_habit_notification_usecase.dart';
import 'package:pursuit/features/habit/domain/usecases/update_goal_count.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/detail/detail_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // 🔹 External
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // 🔹 Notification repository
  sl.registerLazySingleton<NotificationRepository>(
    () => LocalNotificationRepositoryImpl(sl()),
  );

  // 🔹 Notification use case
  sl.registerLazySingleton(() => ScheduleHabitNotificationUseCase(sl()));
  // 🔹 Data source
  sl.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(),
  );

  // 🔹 Repository
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: sl()),
  );

  // 🔹 Use cases
  sl.registerLazySingleton(() => InsertHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetAllHabitsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHabitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetHabitByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateGoalCountUseCase(sl()));
  sl.registerLazySingleton(() => CheckDailyResetUseCase(sl()));

  // 🔹 Bloc
  sl.registerFactory(
    () => HabitBloc(
      insertHabitUseCase: sl(),
      getAllHabitsUseCase: sl(),
      updateHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
      getHabitByIdUseCase: sl(),
      updateGoalCountUseCase: sl(),
      checkDailyResetUseCase: sl(),
      scheduleHabitNotificationUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => DetailBloc(
      updateHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
      getHabitByIdUseCase: sl(),
      updateGoalCountUseCase: sl(),
    ),
  );
}
