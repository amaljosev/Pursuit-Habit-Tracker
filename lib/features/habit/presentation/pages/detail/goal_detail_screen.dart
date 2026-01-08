import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/empty_widget.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/functions/math_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/detail/detail_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/functions/habit_complete_func.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/functions/habit_renew_functions.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/progress_circle_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/glass_animation_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/timer_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/walking_animation.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/progress_page.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';
import 'package:pursuit/features/habit/presentation/widgets/renew_habit.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.habitId, this.habitIcon});
  final String habitId;
  final String? habitIcon;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  bool isCompleteToday = false;
  @override
  void initState() {
    context.read<DetailBloc>().add(GetHabitDetailByIdEvent(widget.habitId));
    super.initState();
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          //context.read<DetailBloc>().add(ResetHabitScreenEvent());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
        },

        child: BlocConsumer<DetailBloc, DetailState>(
          listener: (context, state) {
            if (state is HabitDetailOperationSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            }
            if (state is HabitDetailLoaded) {
              if (state.goalCompletedCount >= state.habit.goalCount &&
                  !state.habit.isCompleteToday) {
                isCompleteToday = true;
              }
            }
          },
          builder: (context, state) {
            // log(state.toString());
            if (state is HabitDetailError) {
              return const ErrorScreenWidget();
            }
            if (state is HabitDetailLoading) {
              return const AppLoading();
            }
            if (state is HabitDetailLoaded) {
              final Habit habit = state.habit;

              final Color goalColor = HelperFunctions.getColorById(
                id: habit.color,
                isDark: true,
              );
              final String goalType = HelperFunctions.getMeasureTypeById(
                habit.goalValue,
              );
              final String goalVal = HelperFunctions.getMeasureById(
                habit.goalValue,
              );
              final String goalIcon = HelperFunctions.getEmojiById(habit.icon);
              return Stack(
                children: [
                  Container(
                    height: context.screenHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HelperFunctions.getColorById(id: habit.color),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: BlocSelector<DetailBloc, DetailState, double>(
                          selector: (state) {
                            if (state is HabitDetailLoaded) {
                              if (state.goalCompletedCount >=
                                      state.habit.goalCount &&
                                  !habit.isCompleteToday) {
                                final updatedHabit = updateHabitOnCompletion(
                                  state.habit,
                                );

                                final isRenewalDay = isHabitEndingToday(habit);

                                if (isRenewalDay) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    renewHabitAlert(
                                      context: context,
                                      habit: updatedHabit,
                                      fromHome: false,
                                      fromRenewScreen: false,
                                    );
                                  });
                                } else {
                                  context.read<DetailBloc>().add(
                                    UpdateHabitDetailEvent(updatedHabit),
                                  );
                                }
                              }
                              return state.goalCompletedCount.toDouble();
                            }
                            return habit.goalCompletedCount.toDouble();
                          },
                          builder: (context, goalCount) {
                            final goalCountInt = goalCount.toInt();
                            return ListView(
                              children: [
                                SafeArea(
                                  child: AppBar(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.black,
                                    surfaceTintColor: Colors.transparent,
                                    leading: BackButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                    ),
                                    title: Text(
                                      habit.name,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                    ),
                                    actions: [OptionsWidget(habit: habit)],
                                  ),
                                ),
                                Column(
                                  spacing: context.screenHeight < 630
                                      ? context.screenHeight * 0.02
                                      : context.screenHeight * 0.05,
                                  children: [
                                    Hero(
                                      tag: habit.id,
                                      child: Text(
                                        widget.habitIcon ?? goalIcon,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayLarge,
                                      ),
                                    ),

                                    goalType == 'distance'
                                        ? WalkingProgressIndicator(
                                            unit:
                                                HelperFunctions.getMeasureById(
                                                  habit.goalValue,
                                                ),
                                            totalGoal: habit.goalCount
                                                .toDouble(),
                                            completedCount: goalCount,
                                            iconEmoji:
                                                widget.habitIcon ?? goalIcon,
                                            primaryColor: goalColor,
                                            secondaryColor: goalColor
                                                .withValues(alpha: 0.5),
                                            onDecrease: goalCountInt <= 0
                                                ? () {}
                                                : () => context
                                                      .read<DetailBloc>()
                                                      .add(
                                                        GoalCountUpdateDetailEvent(
                                                          id: habit.id,
                                                          value:
                                                              goalCountInt - 1,
                                                          habit: habit,
                                                        ),
                                                      ),
                                            onIncrease: () =>
                                                context.read<DetailBloc>().add(
                                                  GoalCountUpdateDetailEvent(
                                                    id: habit.id,
                                                    value: goalCountInt + 1,
                                                    habit: habit,
                                                  ),
                                                ),
                                          )
                                        : goalType == 'time'
                                        ? ModernTimerWidget(
                                            completedGoalCount: goalCountInt,
                                            goalValue: goalVal,
                                            saveTime: () =>
                                                context.read<DetailBloc>().add(
                                                  GoalCountUpdateDetailEvent(
                                                    id: habit.id,
                                                    value: goalCountInt + 1,
                                                    habit: habit,
                                                  ),
                                                ),
                                            onTimerComplete: () =>
                                                context.read<DetailBloc>().add(
                                                  GoalCountUpdateDetailEvent(
                                                    id: habit.id,
                                                    value: habit.goalCount,
                                                    habit: habit,
                                                  ),
                                                ),
                                            onResetTimer: () =>
                                                context.read<DetailBloc>().add(
                                                  GoalCountUpdateDetailEvent(
                                                    id: habit.id,
                                                    value: 0,
                                                    habit: habit,
                                                  ),
                                                ),
                                            totalGoalCount: habit.goalCount,
                                            size: 300,
                                            primaryColor: goalColor,
                                            progressColor: goalColor,
                                          )
                                        : ProgressSection(
                                            habit: habit,
                                            color: goalColor,
                                          ),

                                    goalType != 'time'
                                        ? SafeArea(
                                            child: Form(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => context
                                                        .read<DetailBloc>()
                                                        .add(
                                                          GoalCountUpdateDetailEvent(
                                                            id: habit.id,
                                                            value: 0,
                                                            habit: habit,
                                                          ),
                                                        ),
                                                    child: CircleAvatar(
                                                      backgroundColor: goalColor
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      child: Icon(
                                                        Icons.refresh,
                                                        color: goalColor,
                                                      ),
                                                    ),
                                                  ),
                                                  AppButton(
                                                    title: 'Add',
                                                    backgroundColor: goalColor,
                                                    onPressed:
                                                        goalCountInt >=
                                                            habit.goalCount
                                                        ? null
                                                        : () async {
                                                            final randomNum =
                                                                getRandomInt(
                                                                  habit.goalCount -
                                                                      goalCountInt,
                                                                );
                                                            final input =
                                                                randomNum <= 0
                                                                ? 1
                                                                : randomNum;
                                                            _valueCtrl.text =
                                                                input
                                                                    .toString();
                                                            final result = await numberInputField(
                                                              context: context,
                                                              formKey: _formKey,
                                                              controller:
                                                                  _valueCtrl,
                                                              goalCount: habit
                                                                  .goalCount,

                                                              backgroundColor:
                                                                  HelperFunctions.getColorById(
                                                                    id: habit
                                                                        .color,
                                                                    isDark:
                                                                        true,
                                                                  ),
                                                            );
                                                            if (result !=
                                                                    null &&
                                                                result
                                                                    .isNotEmpty) {
                                                              if (context
                                                                  .mounted) {
                                                                final int val =
                                                                    int.parse(
                                                                      result,
                                                                    );
                                                                context
                                                                    .read<
                                                                      DetailBloc
                                                                    >()
                                                                    .add(
                                                                      GoalCountUpdateDetailEvent(
                                                                        id: habit
                                                                            .id,
                                                                        value:
                                                                            goalCountInt +
                                                                            val,
                                                                        habit:
                                                                            habit,
                                                                      ),
                                                                    );
                                                              }
                                                            }
                                                          },
                                                  ),
                                                  AppButton(
                                                    title: 'Progress',
                                                    icon: CupertinoIcons
                                                        .chart_bar,
                                                    backgroundColor: goalColor,
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProgressPage(
                                                                  habit: habit,
                                                                ),
                                                          ),
                                                        ),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        goalCountInt >=
                                                            habit.goalCount
                                                        ? null
                                                        : () => context
                                                              .read<
                                                                DetailBloc
                                                              >()
                                                              .add(
                                                                GoalCountUpdateDetailEvent(
                                                                  id: habit.id,
                                                                  value: habit
                                                                      .goalCount,
                                                                  habit: habit,
                                                                ),
                                                              ),
                                                    child: CircleAvatar(
                                                      backgroundColor: goalColor
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      child: Icon(
                                                        CupertinoIcons
                                                            .check_mark,
                                                        color: goalColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SafeArea(
                                            top: false,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: AppButton(
                                                    title: 'Progress',
                                                    icon: CupertinoIcons
                                                        .chart_bar,
                                                    backgroundColor: goalColor,
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProgressPage(
                                                                  habit: habit,
                                                                ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  if (isCompleteToday)
                    IgnorePointer(
                      ignoring: true,
                      child: SizedBox(
                        height: context.screenHeight,
                        width: context.screenWidth,
                        child: Lottie.asset(
                          'assets/lottie/party_pop.json',
                          fit: BoxFit.fitWidth,
                          repeat: false,
                        ),
                      ),
                    ),
                ],
              );
            } else {
              return const EmptyWidget();
            }
          },
        ),
      ),
    );
  }
}

class ProgressSection extends StatelessWidget {
  final Habit habit;
  final Color color;

  const ProgressSection({super.key, required this.habit, required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DetailBloc, DetailState, double>(
      selector: (state) {
        if (state is HabitDetailLoaded) {
          return state.goalCompletedCount.toDouble();
        }
        return habit.goalCompletedCount.toDouble();
      },
      builder: (context, completedValue) {
        final int completedCount = completedValue.toInt();
        final goalType = HelperFunctions.getMeasureTypeById(habit.goalValue);
        final goalValue = HelperFunctions.getMeasureById(habit.goalValue);
        return Column(
          children: [
            goalType == 'volume'
                ? WaterFillGlassProgress(
                    totalValue: habit.goalCount.toDouble(),
                    currentValue: completedValue,
                    color: color,
                  )
                : AnimatedRoundedProgress(
                    key: ValueKey('${habit.id}_${habit.goalCount}'),
                    totalValue: habit.goalCount.toDouble(),
                    completedValue: completedValue.toDouble(),
                    color: color,
                  ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                MyCard(
                  onTap: completedCount <= 0
                      ? null
                      : () => context.read<DetailBloc>().add(
                          GoalCountUpdateDetailEvent(
                            id: habit.id,
                            value: completedCount - 1,
                            habit: habit,
                          ),
                        ),
                  value: '-1 $goalValue',
                  backgroundColor: color.withValues(alpha: 0.4),
                  textStyle: TextStyle(color: color),
                ),
                Text(
                  "${completedValue.toInt()} / "
                  "${habit.goalCount} $goalValue",
                ),
                MyCard(
                  onTap: completedCount >= habit.goalCount
                      ? null
                      : () => context.read<DetailBloc>().add(
                          GoalCountUpdateDetailEvent(
                            id: habit.id,
                            value: completedCount + 1,
                            habit: habit,
                          ),
                        ),

                  value: '+1 $goalValue',
                  backgroundColor: color.withValues(alpha: 0.4),
                  textStyle: TextStyle(color: color),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class OptionsWidget extends StatelessWidget {
  const OptionsWidget({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      menuPadding: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      splashRadius: 20,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          labelTextStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleSmall,
          ),
          value: 'edit',
          child: const Row(
            children: [
              Expanded(child: Text('Edit')),
              Icon(Icons.mode_edit_outline_outlined),
            ],
          ),
        ),
        PopupMenuItem<String>(
          labelTextStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.red),
          ),
          value: 'delete',
          child: const Row(
            children: [
              Expanded(child: Text('Delete')),
              Icon(Icons.delete_outline_rounded, color: Colors.red),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'edit') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddHabitScreen(habit: habit),
            ),
          );
        } else if (value == 'delete') {
          onDeleteHabit(context: context, id: habit.id, fromHome: false);
        }
      },
    );
  }
}
