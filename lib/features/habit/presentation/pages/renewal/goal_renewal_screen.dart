import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/detail/detail_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/widgets/renew_habit.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalRenewalScreen extends StatelessWidget {
  const GoalRenewalScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final DateTime? currentEndDate = habit.endDate;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => renewHabitAlert(
        context: context,
        habit: habit,
        fromHome: false,
        fromRenewScreen: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Renew Habit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: false,
          backgroundColor: HelperFunctions.getColorById(id: habit.color),
          elevation: 0,
          scrolledUnderElevation: 1,
          surfaceTintColor: Colors.transparent,
          actionsPadding: const EdgeInsets.only(right: 16),
          actions: [
            MyCard(
              backgroundColor: HelperFunctions.getColorById(
                id: habit.color,
                isDark: true,
              ),
              value: 'Save',
            ),
          ],
        ),
        body: BlocConsumer<HabitBloc, HabitState>(
          listener: (context, state) {
            if (state is HabitUpdateSuccessState) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is HabitError) {
              return const ErrorScreenWidget();
            }
            if (state is HabitLoading) {
              return const AppLoading();
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 20,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Date Section
                        Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current End Date',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        currentEndDate != null
                                            ? "${_getDayName(currentEndDate.weekday)}, ${_getMonthName(currentEndDate.month)} ${currentEndDate.day}, ${currentEndDate.year}"
                                            : 'No end date set',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Colors.grey[200], height: 1),
                        ),

                        // New Date Section
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select New End Date',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose when you want to renew your habit until',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date Picker Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 300,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                minimumDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                initialDateTime: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                maximumYear: DateTime.now().year + 5,
                                backgroundColor: Colors.white,
                                onDateTimeChanged: (DateTime newDate) {
                                  selectedDate = newDate;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          title: 'Save',
                          backgroundColor: HelperFunctions.getColorById(
                            id: habit.color,
                            isDark: true,
                          ),
                          onPressed: () {
                            final updatedHabit = Habit(
                              id: habit.id,
                              name: habit.name,
                              icon: habit.icon,
                              color: habit.color,
                              type: habit.type,
                              goalValue: habit.goalValue,
                              goalCount: habit.goalCount,
                              time: habit.time,
                              startDate: habit.startDate,
                              endDate: selectedDate,
                              goalCompletedCount: habit.goalCompletedCount,
                              goalRecordCount: habit.goalRecordCount,
                              isCompleteToday: habit.isCompleteToday,
                              streakCount: habit.streakCount,
                              bestStreak: habit.bestStreak,
                              countThisMonth: habit.countThisMonth,
                              countLastMonth: habit.countLastMonth,
                              countThisWeek: habit.countThisWeek,
                              countLastWeek: habit.countLastWeek,
                              countThisYear: habit.countThisYear,
                              countLastYear: habit.countLastYear,
                              completedDays: habit.completedDays,
                              achievements: habit.achievements,
                            );
                            context.read<DetailBloc>().add(
                              ResetHabitScreenEvent(),
                            );
                            context.read<HabitBloc>().add(
                              UpdateHabitEvent(updatedHabit),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
