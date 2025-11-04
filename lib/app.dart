import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';
import 'core/di/injection_container.dart';

import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<HabitBloc>(create: (_) => sl<HabitBloc>())],
      child: MaterialApp(
        title: 'Pursuit: Habit Tracker',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
