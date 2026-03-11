import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/services/app_update_service.dart';
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
    // Reschedule any reminders that were skipped yesterday
    context.read<HabitBloc>().rescheduleSkippedReminders();
    AppUpdateService().checkForBackgroundUpdate();
    // Navigate after a short splash delay
    Future.delayed(const Duration(milliseconds: 1200), _navigateToHome);
  }

  Future<void> _navigateToHome() async {
    if (!_hasNavigated && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final showOnboarding = prefs.getBool('showOnboarding');
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => (showOnboarding ?? false)
              ? const HomePage()
              : const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/pursuit_icon.png', height: 80, width: 80),
            Text(
              'Pursuit',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}