import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app.dart';
import 'package:pursuit/core/di/injection_container.dart' as di;
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<HabitBloc>()..add(GetAllHabitsEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
