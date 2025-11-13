import 'package:flutter/material.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('data'),
      ),
    );
  }
}