import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/onboarding/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    context.read<HabitBloc>().add(CheckDailyResetEvent());
  }

  Future<void> _navigateToHome() async {
    if (!_hasNavigated && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final showOnboarding = await prefs.getBool('showOnboarding');
      _hasNavigated = true;
      if (showOnboarding != null && showOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Image.asset(
                'assets/icon/pursuit_icon.png',
                height: 80,
                width: 80,
              ),
              Text(
                'Pursuit',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w900),
              ),

              const SizedBox(height: 16),

              // Dynamic loading text based on state
              BlocBuilder<HabitBloc, HabitState>(
                builder: (context, state) {
                  String loadingText = 'Getting things ready...';

                  if (state is HabitLoading) {
                    loadingText = 'Checking daily progress...';
                  } else if (state is HabitDailyResetCompleted) {
                    loadingText = '';
                  } else if (state is HabitError) {
                    loadingText = 'Loading app...';
                  }

                  return Text(
                    loadingText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
