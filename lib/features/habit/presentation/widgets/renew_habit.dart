import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/detail/detail_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/renewal/goal_renewal_screen.dart';

void renewHabitAlert({
  required BuildContext context,
  required Habit habit,
  required bool? fromHome,
}) {
  showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(CupertinoIcons.refresh, color: Colors.blue.shade600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text(
              'Habit Period Ended',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'This habit period has ended. Would you like to renew this habit and continue tracking your progress?\n\n'
              'If you choose not to renew, this habit along with all its progress data will be deleted.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          AppButton(
            title: 'Not Now',
            backgroundColor: Colors.blue.shade50,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.blue.shade600),
            onPressed: () {
              if (fromHome != null && fromHome) {
                context.read<HabitBloc>().add(DeleteHabitEvent(habit.id));
              } else {
                context.read<DetailBloc>().add(DeleteHabitDetailEvent(habit.id));
              }
      
              Navigator.pop(context);
            },
            elevation: const WidgetStatePropertyAll(0),
          ),
          AppButton(
            title: 'Renew Habit',
            backgroundColor: Colors.blue.shade600,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    GoalRenewalScreen(habit: habit),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
