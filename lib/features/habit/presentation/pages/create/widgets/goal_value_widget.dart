import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/features/habit/constants/habit_measures.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';
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
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 20,
                            right: 20,
                            top: 20,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 20,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Enter value (Count)",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: valueCtrl,
                                  keyboardType: TextInputType.number,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    hintText: "eg: 20",
                                    filled: true,
                                    fillColor: backgroundColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return null;
                                    }
                                    final numberRegex = RegExp(r'^\d*\.?\d+$');
                                    if (!numberRegex.hasMatch(value.trim())) {
                                      return 'Enter a valid number';
                                    }
                                    final number = int.parse(value);
                                    if (number < 1) {
                                      return 'Minimum 1 is required';
                                    }

                                    if (value.length > 5) {
                                      return 'Number is too long';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    if (formKey.currentState!.validate()) {
                                      Navigator.pop(context, value);
                                    }
                                  },
                                ),

                                SafeArea(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          backgroundColor: backgroundColor,
                                          title: 'Save',
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Navigator.pop(
                                                context,
                                                valueCtrl.text,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
