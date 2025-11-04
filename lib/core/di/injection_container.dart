import 'package:get_it/get_it.dart';
import 'package:pursuit/features/habit/data/datasources/habit_local_datasource.dart';
import 'package:pursuit/features/habit/data/repositories/habit_repository_implementation.dart';
import 'package:pursuit/features/habit/domain/repositories/habit_repository.dart';
import 'package:pursuit/features/habit/domain/usecases/delete_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_habit_by_id.dart';
import 'package:pursuit/features/habit/domain/usecases/insert_habit.dart';
import 'package:pursuit/features/habit/domain/usecases/get_all_habits.dart';
import 'package:pursuit/features/habit/domain/usecases/update_habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
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

// 🔹 Bloc
sl.registerFactory(
  () => HabitBloc(
    insertHabitUseCase: sl(),
    getAllHabitsUseCase: sl(),
    updateHabitUseCase: sl(),
    deleteHabitUseCase: sl(),
    getHabitByIdUseCase: sl(),
  ),
);

}
