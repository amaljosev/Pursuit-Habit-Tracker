import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/progress_circle_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/glass_animation_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/timer_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/walking_animation.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.habitId});
  final String habitId;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  @override
  void initState() {
    context.read<HabitBloc>().add(GetHabitByIdEvent(widget.habitId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: BlocConsumer<HabitBloc, HabitState>(
          listener: (context, state) {
            if (state is HabitOperationSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            }
            if (state is HabitCountUpdateSuccess) {
              context.read<HabitBloc>().add(GetHabitByIdEvent(widget.habitId));
            }
          },
          builder: (context, state) {
            if (state is HabitError) {
              return const ErrorScreenWidget();
            }
            if (state is HabitLoading) {
              return const AppLoading();
            }
            if (state is HabitDetailLoaded) {
              final Habit habit = state.habit;
              return GoalDetailContent(
                habit: habit,
                formKey: _formKey,
                valueCtrl: _valueCtrl,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

class GoalDetailContent extends StatelessWidget {
  const GoalDetailContent({
    super.key,
    required this.habit,
    required this.formKey,
    required this.valueCtrl,
  });
  final Habit habit;
  final GlobalKey<FormState> formKey;
  final TextEditingController valueCtrl;

  @override
  Widget build(BuildContext context) {
    final color = HelperFunctions.getColorById(id: habit.color, isDark: true);
    final goalType = HelperFunctions.getMeasureTypeById(habit.goalValue);
    final goalVal = HelperFunctions.getMeasureById(habit.goalValue);

    return Stack(
      alignment: AlignmentGeometry.center,
      children: [
        Container(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 20,
                children: [
                  Column(
                    children: [
                      SafeArea(
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          surfaceTintColor: Colors.transparent,
                          leading: BackButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                              (route) => false,
                            ),
                          ),
                          title: Text(
                            habit.name,
                            style: const TextStyle(color: Colors.black),
                            maxLines: 2,
                          ),
                          actions: [OptionsWidget(habit: habit)],
                        ),
                      ),
                      Text(
                        HelperFunctions.getEmojiById(habit.icon),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),

                  goalType == 'distance'
                      ? WalkingProgressIndicator(
                          unit: HelperFunctions.getMeasureById(habit.goalValue),
                          totalGoal: habit.goalCount.toDouble(),
                          completedCount: habit.goalCompletedCount.toDouble(),
                          iconEmoji: HelperFunctions.getEmojiById(habit.icon),
                          primaryColor: color,
                          secondaryColor: color.withValues(alpha: 0.5),
                          onDecrease: habit.goalCompletedCount <= 0
                              ? () {}
                              : () => context.read<HabitBloc>().add(
                                  GoalCountUpdateEvent(
                                    id: habit.id,
                                    value: habit.goalCompletedCount - 1,
                                  ),
                                ),
                          onIncrease: () => context.read<HabitBloc>().add(
                            GoalCountUpdateEvent(
                              id: habit.id,
                              value: habit.goalCompletedCount + 1,
                            ),
                          ),
                        )
                      : goalType == 'time'
                      ? Expanded(
                          child: ModernTimerWidget(
                            key: ValueKey(habit.goalCompletedCount),
                            completedGoalCount: habit.goalCompletedCount,
                            goalValue: goalVal,
                            saveTime: () => context.read<HabitBloc>().add(
                              GoalCountUpdateEvent(
                                id: habit.id,
                                value: habit.goalCompletedCount + 1,
                              ),
                            ),
                            onTimerComplete: () =>
                                context.read<HabitBloc>().add(
                                  GoalCountUpdateEvent(
                                    id: habit.id,
                                    value: habit.goalCount,
                                  ),
                                ),
                            onResetTimer: () => context.read<HabitBloc>().add(
                              GoalCountUpdateEvent(id: habit.id, value: 0),
                            ),
                            totalGoalCount: habit.goalCount,
                            size: 300,
                            primaryColor: color,
                            progressColor: color,
                          ),
                        )
                      : ProgressSection(habit: habit, color: color),

                  if (goalType != 'time')
                    SafeArea(
                      child: Form(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<HabitBloc>().add(
                                GoalCountUpdateEvent(id: habit.id, value: 0),
                              ),
                              child: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.2),
                                child: Icon(Icons.refresh, color: color),
                              ),
                            ),
                            AppButton(
                              title: 'Add',
                              backgroundColor: color,
                              onPressed: () async {
                                valueCtrl.text = habit.goalCount > 2
                                    ? (habit.goalCount - 2).toString()
                                    : '1';
                                final result = await numberInputField(
                                  context: context,
                                  formKey: formKey,
                                  controller: valueCtrl,
                                  goalCount: habit.goalCount,
                                  backgroundColor: HelperFunctions.getColorById(
                                    id: habit.color,
                                    isDark: true,
                                  ),
                                );
                                if (result != null && result.isNotEmpty) {
                                  if (context.mounted) {
                                    final int val = int.parse(result);
                                    context.read<HabitBloc>().add(
                                      GoalCountUpdateEvent(
                                        id: habit.id,
                                        value: habit.goalCompletedCount + val,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            GestureDetector(
                              onTap: () => context.read<HabitBloc>().add(
                                GoalCountUpdateEvent(
                                  id: habit.id,
                                  value: habit.goalCount,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.2),
                                child: Icon(Icons.check, color: color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (habit.goalCompletedCount == habit.goalCount)
          Lottie.asset('assets/lottie/party_pop.json', repeat: false),
      ],
    );
  }
}

class ProgressSection extends StatelessWidget {
  final Habit habit;
  final Color color;

  const ProgressSection({super.key, required this.habit, required this.color});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HabitBloc, HabitState, double>(
      selector: (state) {
        if (state is HabitDetailLoaded) {
          return state.habit.goalCompletedCount.toDouble();
        } else if (state is HabitCountUpdateSuccess) {
          return state.updatedCount.toDouble();
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
                    currentValue: habit.goalCompletedCount.toDouble(),
                    color: color,
                  )
                : AnimatedRoundedProgress(
                    totalValue: habit.goalCount.toDouble(),
                    completedValue: completedValue,
                    color: color,
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                MyCard(
                  onTap: () => context.read<HabitBloc>().add(
                    GoalCountUpdateEvent(
                      id: habit.id,
                      value: completedCount - 1,
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
                  onTap: () => context.read<HabitBloc>().add(
                    GoalCountUpdateEvent(
                      id: habit.id,
                      value: completedCount + 1,
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
          onDeleteHabit(context: context, id: habit.id);
        }
      },
    );
  }
}
