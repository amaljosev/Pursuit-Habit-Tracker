import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/splash/splash_screen.dart';
import 'package:pursuit/features/onboarding/onboarding_page.dart';
import 'core/di/injection_container.dart';

import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: MultiBlocProvider(
        providers: [BlocProvider<HabitBloc>(create: (_) => sl<HabitBloc>())],
        child: MaterialApp(
          title: 'Pursuit: Habit Tracker',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => SplashScreen(),
            '/add': (context) => AddHabitScreen(),
            '/onboarding':(context)=>OnboardingScreen()
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}
