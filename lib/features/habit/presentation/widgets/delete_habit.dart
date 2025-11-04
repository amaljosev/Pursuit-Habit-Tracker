import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';

void onDeleteHabit({required BuildContext context, required String id}) {
  showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: CircleAvatar(
        backgroundColor: Colors.red.shade50,
        child: Icon(CupertinoIcons.delete, color: Colors.red.shade500),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Text('Deleting Goal', style: Theme.of(context).textTheme.titleMedium),
          Text(
            "Do you really want to remove this habit? You won’t be able to get it back.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],

      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        AppButton(
          title: 'Cancel',
          backgroundColor: Colors.red.shade50,
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: Colors.red.shade500),
          onPressed: () => Navigator.pop(context),
          elevation: WidgetStatePropertyAll(0),
        ),
        AppButton(
          title: 'Delete',
          backgroundColor: Colors.red.shade600,
          onPressed: () {
            context.read<HabitBloc>().add(DeleteHabitEvent(id));
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
