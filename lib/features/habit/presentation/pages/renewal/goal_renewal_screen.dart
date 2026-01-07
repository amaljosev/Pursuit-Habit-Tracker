import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/widgets/date_picker_widget.dart';

class GoalRenewalScreen extends StatelessWidget {
  const GoalRenewalScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final DateTime? currentEndDate = habit.endDate;
    return Scaffold(
      appBar: AppBar(title: const Text('Renew Habit'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Habit Info
            Row(
              children: [
                Text(
                 HelperFunctions.getEmojiById(habit.icon),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Current End Date Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current End Date',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentEndDate != null
                            ? "${currentEndDate.day}-${currentEndDate.month}-${currentEndDate.year}"
                            : 'Not set',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _openDatePicker(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Info Text
            Text(
              'Extend your habit by selecting a new end date. '
              'Your progress will continue from where you left off.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Spacer(),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // context.read<HabitBloc>().add(
                  //   ConfirmHabitRenewalEvent(habitId: habit.id),
                  // );
                  // Navigator.pop(context);
                },
                child: const Text('Save & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Sheet Date Picker
  void _openDatePicker(BuildContext context) {
    showBottomSheet(
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDatePicker(
                onDateSelected: (day, month, year) {
                  // context.read<HabitBloc>().add(
                  //   HabitEndDateEvent(
                  //     endDate: day == 0 && month == 0 && year == 0
                  //         ? ''
                  //         : DateTime(year, month, day).toIso8601String(),
                  //   ),
                  // );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
