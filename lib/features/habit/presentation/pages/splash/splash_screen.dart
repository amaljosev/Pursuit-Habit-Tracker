import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Trigger daily reset check when screen loads
   context.read<HabitBloc>().add( CheckDailyResetEvent());
  }

  void _navigateToHome() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          // Navigate to home when reset completes or if there's an error
          if (state is HabitDailyResetCompleted || state is HabitError) {
            // Small delay to show completion state
            Future.delayed(const Duration(milliseconds: 500), _navigateToHome);
          }

        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon/logo
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              
              // App name
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Loading indicator
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              
              // Dynamic loading text based on state
              BlocBuilder<HabitBloc, HabitState>(
                builder: (context, state) {
                  String loadingText = 'Getting things ready...';
                  
                  if (state is HabitLoading) {
                    loadingText = 'Checking daily progress...';
                  } else if (state is HabitDailyResetCompleted) {
                    loadingText = 'Ready!';
                  } else if (state is HabitError) {
                    loadingText = 'Loading app...';
                  }
                  
                  return Text(
                    loadingText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}