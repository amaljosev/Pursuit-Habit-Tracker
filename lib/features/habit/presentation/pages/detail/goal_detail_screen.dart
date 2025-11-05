import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/progress_circle_widget.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.habitId});
  final String habitId;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
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
              return Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 20,
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        surfaceTintColor: Colors.transparent,
                        leading: BackButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                            (Route<dynamic> route) => false,
                          ),
                        ),
                        title: Text(
                          habit.name,
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [OptionsWidget(habit: habit)],
                      ),
                      MyCard(
                        backgroundColor: HelperFunctions.getColorById(
                          id: habit.color,
                          isDark: true,
                        ),
                        value:
                            "Goal to ${HelperFunctions.getTypeById(habit.type)}",
                      ),
              
                      Stack(
                        alignment: AlignmentGeometry.center,
                        children: [
                          // AnimatedCircularProgress(
                          //   totalValue: habit.goalCount.toDouble(),
                          //   currentValue: habit.goalCompletedCount.toDouble(),
                          //   color: HelperFunctions.getColorById(
                          //     id: habit.color,
                          //     isDark: true,
                          //   ),
                          //   strokeWidth: 20.0,
                          //   size: 300,
                          // ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        context.read<HabitBloc>().add(
                                          GoalCountIncrementEvent(
                                            id: habit.id,
                                            value:
                                                habit.goalCompletedCount - 1,
                                          ),
                                        ),
                                    icon: Icon(Icons.remove),
                                  ),
                                  Text(
                                    HelperFunctions.getEmojiById(habit.icon),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayLarge,
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        context.read<HabitBloc>().add(
                                          GoalCountIncrementEvent(
                                            id: habit.id,
                                            value:
                                                habit.goalCompletedCount + 1,
                                          ),
                                        ),
                                    icon: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
              
                      WaterFillGlassProgress(
                        totalValue: habit.goalCount.toDouble(),
                        currentValue: habit.goalCompletedCount.toDouble(),
                        color: Colors.blue,
                      ),
                      Text(
                        "${habit.goalCompletedCount} ${HelperFunctions.getMeasureById(habit.goalValue)} / ${habit.goalCount} ${HelperFunctions.getMeasureById(habit.goalValue)}",
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: HelperFunctions.getColorById(
                              id: habit.color,
                              isDark: true,
                            ),
                            child: Icon(Icons.refresh),
                          ),
                          AppButton(
                            title: 'Add',
                            backgroundColor: HelperFunctions.getColorById(
                              id: habit.color,
                              isDark: true,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: HelperFunctions.getColorById(
                              id: habit.color,
                              isDark: true,
                            ),
                            child: Icon(Icons.check),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

class AnimatedCircularProgress extends StatefulWidget {
  final double totalValue;
  final double currentValue;
  final Color color;
  final double strokeWidth;
  final double size;
  final Color backgroundColor;

  const AnimatedCircularProgress({
    super.key,
    required this.totalValue,
    required this.currentValue,
    required this.color,
    this.strokeWidth = 10.0,
    this.size = 120.0,
    this.backgroundColor = Colors.grey,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.currentValue;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animateTo(widget.currentValue);
  }

  @override
  void didUpdateWidget(covariant AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _oldValue = oldWidget.currentValue;
      _animateTo(widget.currentValue);
    }
  }

  void _animateTo(double newValue) {
    final oldProgress = (_oldValue / widget.totalValue).clamp(0.0, 1.0);
    final newProgress = (newValue / widget.totalValue).clamp(0.0, 1.0);

    _animation = Tween<double>(
      begin: oldProgress,
      end: newProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CircularProgressIndicator(
            year2023: false,
            value: _animation.value,
            strokeWidth: widget.strokeWidth,
            color: widget.color,
            backgroundColor: widget.backgroundColor,
          );
        },
      ),
    );
  }
}
