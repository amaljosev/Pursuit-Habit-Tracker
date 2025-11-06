import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/constants/habit_measures.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalValueWidget extends StatelessWidget {
  const GoalValueWidget({
    super.key,
    required this.backgroundColor,
    required this.formKey,
    required this.valueCtrl,
  });

  final Color backgroundColor;
  final GlobalKey<FormState> formKey;
  final TextEditingController valueCtrl;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Text('Goal Value'),
      leadingAndTrailingTextStyle: Theme.of(context).textTheme.titleMedium,

      title: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BlocBuilder<HabitBloc, HabitState>(
            buildWhen: (previous, current) {
              if (previous is AddHabitInitial && current is AddHabitInitial) {
                return previous.goalCount != current.goalCount;
              }

              return false;
            },
            builder: (context, state) {
              if (state is AddHabitInitial) {
                return MyCard(
                  backgroundColor: backgroundColor,
                  value: state.goalCount.toString(),
                  onTap: () async {
                    valueCtrl.text = state.goalCount.toString();
                    final result = await numberInputField(
                      context: context,
                      formKey: formKey,
                      backgroundColor: backgroundColor,
                      controller: valueCtrl,
                    );
                    if (result != null && result.isNotEmpty) {
                      if (context.mounted) {
                        context.read<HabitBloc>().add(
                          HabitGoalCountEvent(goalCount: int.parse(result)),
                        );
                      }
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          BlocBuilder<HabitBloc, HabitState>(
            buildWhen: (previous, current) {
              if (previous is AddHabitInitial && current is AddHabitInitial) {
                return previous.goalValue != current.goalValue;
              }
              return false;
            },
            builder: (context, state) {
              if (state is AddHabitInitial) {
                return MyCard(
                  backgroundColor: backgroundColor,
                  value: HabitMeasures.measures[state.goalValue]['name'],
                  onTap: () async {
                    final int? result = await showModalBottomSheet(
                      showDragHandle: true,
                      backgroundColor: Colors.white,
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: SafeArea(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 20,
                                runAlignment: WrapAlignment.center,
                                children: List.generate(
                                  HabitMeasures.measures.length,
                                  (index) {
                                    final String measures =
                                        HabitMeasures.measures[index]['name'];
                                    final int id =
                                        HabitMeasures.measures[index]['id'];
                                    return MyCard(
                                      backgroundColor: backgroundColor,
                                      value: measures,

                                      onTap: () => Navigator.pop(context, id),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    if (result != null) {
                      if (context.mounted) {
                        context.read<HabitBloc>().add(
                          HabitGoalValueEvent(goalValue: result),
                        );
                      }
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          Text('/ Day'),
        ],
      ),
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
