import 'package:flutter/material.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';

class GoalsEmptyWidget extends StatelessWidget {
  const GoalsEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_circle_rounded,
            size: 120,
            color: Colors.blueAccent.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            "No Goals Yet!",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            "Start by creating your first goal.\nTrack your habits, stay consistent, and grow!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            title: 'New Goal',
            icon: Icons.add,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => AddHabitScreen())),
          ),
        ],
      ),
    );
  }
}
