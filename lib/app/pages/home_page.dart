import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoalsScreen(),
      
    );
  }
}

