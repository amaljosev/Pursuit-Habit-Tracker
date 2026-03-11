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
import 'package:pursuit/features/habit/presentation/pages/detail/functions/habit_renew_functions.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/progress_circle_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/widgets/glass_animation_widget.dart';
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

  bool _showPartyAnimation = false;

  /// The count value from the PREVIOUS state emission.
  /// Used to detect an upward crossing of goalCount so the animation
  /// only fires on the exact tap that completes the habit — not on
  /// every subsequent rebuild.
  int? _prevCompletedCount;

  @override
  void initState() {
    super.initState();
    context.read<DetailBloc>().add(GetHabitDetailByIdEvent(widget.habitId));
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          );
        },
        child: BlocConsumer<DetailBloc, DetailState>(
          listener: (context, state) {
            if (state is HabitDetailOperationSuccess) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
                (route) => false,
              );
            }

            if (state is HabitDetailLoaded) {
              final habit = state.habit;
              final currentCount = state.goalCompletedCount;
              final prev = _prevCompletedCount;

              // prev == null guard skips the very first load (no animation on open).
              final crossedThreshold = prev != null &&
                  prev < habit.goalCount &&
                  currentCount >= habit.goalCount;

              if (crossedThreshold && !_showPartyAnimation) {
                setState(() => _showPartyAnimation = true);

                if (isHabitEndingToday(habit)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    renewHabitAlert(
                      context: context,
                      habit: habit,
                      fromHome: false,
                      fromRenewScreen: false,
                    );
                  });
                }
              }

              // Reset animation flag when user resets count below goal
              if (currentCount < habit.goalCount && _showPartyAnimation) {
                setState(() => _showPartyAnimation = false);
              }

              // Always update prev for next comparison
              _prevCompletedCount = currentCount;
            }
          },
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            if (state is HabitDetailError) return const ErrorScreenWidget();
            if (state is HabitDetailLoading) return const AppLoading();

            if (state is HabitDetailLoaded) {
              final Habit habit = state.habit;
              final Color goalColor =
                  HelperFunctions.getColorById(id: habit.color, isDark: true);
              final String goalType =
                  HelperFunctions.getMeasureTypeById(habit.goalValue);
              final String goalIcon = HelperFunctions.getEmojiById(habit.icon);

              return Stack(
                children: [
                  Container(
                    height: context.screenHeight,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? null
                          : LinearGradient(
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
                        child: BlocSelector<DetailBloc, DetailState, int>(
                          selector: (s) => s is HabitDetailLoaded
                              ? s.goalCompletedCount
                              : habit.goalCompletedCount,
                          builder: (context, goalCountInt) {
                            return Column(
                              children: [
                                // ── APP BAR ──
                                AppBar(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor:
                                      isDark ? Colors.white : Colors.black,
                                  surfaceTintColor: Colors.transparent,
                                  elevation: 0,
                                  leading: BackButton(
                                    onPressed: () =>
                                        Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HomePage()),
                                      (route) => false,
                                    ),
                                  ),
                                  title: Text(
                                    habit.name,
                                    maxLines: 2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                  ),
                                  actions: [
                                    OptionsWidget(
                                        habit: habit, isDark: isDark),
                                  ],
                                ),

                                // ── CONTENT ──
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Hero(
                                            tag: habit.id,
                                            child: Text(
                                              widget.habitIcon ?? goalIcon,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          if (goalType == 'distance')
                                            WalkingProgressIndicator(
                                              unit: HelperFunctions
                                                  .getMeasureById(
                                                      habit.goalValue),
                                              totalGoal:
                                                  habit.goalCount.toDouble(),
                                              completedCount:
                                                  goalCountInt.toDouble(),
                                              iconEmoji: widget.habitIcon ??
                                                  goalIcon,
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
                                              onIncrease: () => context
                                                  .read<DetailBloc>()
                                                  .add(
                                                    GoalCountUpdateDetailEvent(
                                                      id: habit.id,
                                                      value: goalCountInt + 1,
                                                      habit: habit,
                                                    ),
                                                  ),
                                            )
                                          else
                                            ProgressSection(
                                              habit: habit,
                                              color: goalColor,
                                              isDark: isDark,
                                            ),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // ── BOTTOM ACTIONS ──
                                SafeArea(
                                  top: false,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            context.read<DetailBloc>().add(
                                                  GoalCountUpdateDetailEvent(
                                                    id: habit.id,
                                                    value: 0,
                                                    habit: habit,
                                                  ),
                                                ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              goalColor.withValues(alpha: 0.2),
                                          child: Icon(Icons.refresh,
                                              color: goalColor),
                                        ),
                                      ),
                                      AppButton(
                                        title: 'Add',
                                        backgroundColor: goalColor,
                                        onPressed:
                                            goalCountInt >= habit.goalCount
                                                ? null
                                                : () async {
                                                    final randomNum =
                                                        getRandomInt(
                                                      habit.goalCount -
                                                          goalCountInt,
                                                    );
                                                    _valueCtrl.text =
                                                        (randomNum <= 0
                                                                ? 1
                                                                : randomNum)
                                                            .toString();
                                                    final result =
                                                        await numberInputField(
                                                      context: context,
                                                      formKey: _formKey,
                                                      controller: _valueCtrl,
                                                      goalCount:
                                                          habit.goalCount,
                                                      backgroundColor:
                                                          HelperFunctions
                                                              .getColorById(
                                                        id: habit.color,
                                                        isDark: true,
                                                      ),
                                                      isDarkMode: isDark,
                                                    );
                                                    if (result != null &&
                                                        result.isNotEmpty &&
                                                        context.mounted) {
                                                      context
                                                          .read<DetailBloc>()
                                                          .add(
                                                            GoalCountUpdateDetailEvent(
                                                              id: habit.id,
                                                              value: goalCountInt +
                                                                  int.parse(
                                                                      result),
                                                              habit: habit,
                                                            ),
                                                          );
                                                    }
                                                  },
                                      ),
                                      AppButton(
                                        title: 'Progress',
                                        icon: CupertinoIcons.chart_bar,
                                        backgroundColor: goalColor,
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProgressPage(habit: habit),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: goalCountInt >= habit.goalCount
                                            ? null
                                            : () =>
                                                context.read<DetailBloc>().add(
                                                      GoalCountUpdateDetailEvent(
                                                        id: habit.id,
                                                        value: habit.goalCount,
                                                        habit: habit,
                                                      ),
                                                    ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              goalColor.withValues(alpha: 0.2),
                                          child: Icon(
                                              CupertinoIcons.check_mark,
                                              color: goalColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 🎉 Party animation — fires ONLY on threshold crossing
                  if (_showPartyAnimation)
                    IgnorePointer(
                      child: Lottie.asset(
                        'assets/lottie/party_pop.json',
                        fit: isTablet ? BoxFit.contain : BoxFit.fitHeight,
                        height: context.screenHeight,
                        width: isTablet ? context.screenWidth : null,
                        repeat: false,
                      ),
                    ),
                ],
              );
            }

            return const EmptyWidget();
          },
        ),
      ),
    );
  }
}

// ─── Progress Section ──────────────────────────────────────────────────────────

class ProgressSection extends StatelessWidget {
  final Habit habit;
  final Color color;
  final bool isDark;

  const ProgressSection({
    super.key,
    required this.habit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DetailBloc, DetailState, int>(
      selector: (state) => state is HabitDetailLoaded
          ? state.goalCompletedCount
          : habit.goalCompletedCount,
      builder: (context, completedCount) {
        final goalType = HelperFunctions.getMeasureTypeById(habit.goalValue);
        final goalValue = HelperFunctions.getMeasureById(habit.goalValue);

        return Column(
          children: [
            goalType == 'volume'
                ? WaterFillGlassProgress(
                    totalValue: habit.goalCount.toDouble(),
                    currentValue: completedCount.toDouble(),
                    color: color,
                  )
                : AnimatedRoundedProgress(
                    key: ValueKey('${habit.id}_${habit.goalCount}'),
                    totalValue: habit.goalCount.toDouble(),
                    completedValue: completedCount.toDouble(),
                    color: color,
                  ),
            const SizedBox(height: 20),
            Text(
              '$completedCount / ${habit.goalCount} $goalValue',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 20),
                  onTap: completedCount <= 0
                      ? null
                      : () => context.read<DetailBloc>().add(
                            GoalCountUpdateDetailEvent(
                              id: habit.id,
                              value: completedCount - 1,
                              habit: habit,
                            ),
                          ),
                  value: '-1  $goalValue',
                  backgroundColor: color.withValues(alpha: 0.4),
                  textStyle:
                      Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: isDark ? Colors.white : color,
                            fontWeight: FontWeight.w900,
                          ),
                ),
                const SizedBox(width: 20),
                MyCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 20),
                  onTap: completedCount >= habit.goalCount
                      ? null
                      : () => context.read<DetailBloc>().add(
                            GoalCountUpdateDetailEvent(
                              id: habit.id,
                              value: completedCount + 1,
                              habit: habit,
                            ),
                          ),
                  value: '+1  $goalValue',
                  backgroundColor: color.withValues(alpha: 0.4),
                  textStyle:
                      Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: isDark ? Colors.white : color,
                            fontWeight: FontWeight.w900,
                          ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─── Options popup ─────────────────────────────────────────────────────────────

class OptionsWidget extends StatelessWidget {
  const OptionsWidget({super.key, required this.habit, required this.isDark});
  final Habit habit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      menuPadding: EdgeInsets.zero,
      padding: const EdgeInsets.all(8),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      splashRadius: 20,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Expanded(child: Text('Edit')),
            Icon(Icons.mode_edit_outline_outlined,
                color: isDark ? Colors.white : Colors.black),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Expanded(
                child:
                    Text('Delete', style: TextStyle(color: Colors.red))),
            Icon(Icons.delete_outline_rounded, color: Colors.red),
          ]),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddHabitScreen(habit: habit)));
        } else if (value == 'delete') {
          onDeleteHabit(context: context, id: habit.id, fromHome: false);
        }
      },
    );
  }
}