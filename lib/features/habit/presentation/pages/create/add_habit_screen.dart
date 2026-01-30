import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/color_picker.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/goal_end_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/goal_time_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/goal_value_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/habit_remainder_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/habit_title_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/habit_type_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/create/widgets/icon_picker_widget.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/goal_detail_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_library_screen.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key, this.habit, this.customHabit});
  final Habit? habit;
  final LibraryModel? customHabit;

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.customHabit != null && widget.habit == null) {
      nameController.text = widget.customHabit!.title;
      context.read<HabitBloc>().add(
        CustomHabitInitialEvent(customHabit: widget.customHabit!),
      );
    } else if (widget.habit != null && widget.customHabit == null) {
      context.read<HabitBloc>().add(
        UpdateHabitInitialEvent(habit: widget.habit!),
      );
      nameController.text = widget.habit!.name;
    } else {
      context.read<HabitBloc>().add(AddHabitInitialEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: widget.habit == null,

      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(habitId: widget.habit!.id),
            ),
            (Route<dynamic> route) => false,
          );
        }
      },
      child: _HabitView(
        nameController: nameController,
        formKey: formKey,
        habit: widget.habit,
        customHabit: widget.customHabit,
        isDark: isDark,
      ),
    );
  }
}

class _HabitView extends StatelessWidget {
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final Habit? habit;
  final LibraryModel? customHabit;
  final bool isDark;
  const _HabitView({
    required this.nameController,
    required this.formKey,
    required this.habit,
    required this.customHabit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitOperationSuccess) {
            if (habit != null) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalDetailScreen(habitId: habit!.id),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false,
              );
            }
          }
          if (state is HabitUpdateSuccessState && habit != null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => GoalDetailScreen(habitId: habit!.id),
              ),
              (Route<dynamic> route) => false,
            );
          }
        },
        buildWhen: (previous, current) {
          if (previous is AddHabitInitial && current is AddHabitInitial) {
            return previous.color != current.color;
          }
          return true;
        },
        builder: (context, state) {
          if (state is AddHabitInitial) {
            final Color backgroundColorLight =
                AppColors.lightColors[state.color]['color'];
            final Color backgroundColorDark =
                AppColors.darkColors[state.color]['color'];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: MediaQuery.of(context).size.height,
              color: backgroundColorLight,
              child: Padding(
                padding: EdgeInsets.all(context.screenWidth * 0.04),
                child: CustomScrollView(
                  slivers: [
                    // Top app bar sliver
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      expandedHeight: 0,
                      pinned: true,
                      toolbarHeight: kToolbarHeight,
                      flexibleSpace: AppBar(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        surfaceTintColor: Colors.transparent,
                        leading: BackButton(
                          onPressed: () {
                            if (habit != null) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GoalDetailScreen(habitId: habit!.id),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        actions: [
                          MyCard(
                            backgroundColor: backgroundColorDark,
                            value: habit != null ? 'Update' : 'Save',
                            onTap: () => formKey.currentState!.validate()
                                ? _saveHabit(
                                    context: context,
                                    isUpdate: habit != null,
                                    updateHabit: habit,
                                  )
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Please give required data',
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Content sliver
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Form(
                          key: formKey,
                          child: Column(
                            spacing: 10,
                            children: [
                              const IconPickerWidget(),
                              InputFieldWidget(
                                controller: nameController,
                                color: backgroundColorDark,
                                formKey: formKey,
                              ),
                              const ColorPickerWidget(),
                              HabitTypeWidget(bgColor: state.color),
                              GoalWidget(
                                backgroundColor: backgroundColorDark,
                                isDark: isDark,
                              ),
                              HabitRemainderWidget(
                                backgroundColor: backgroundColorDark,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      title: habit != null ? 'Update' : 'Save',
                                      backgroundColor: backgroundColorDark,
                                      onPressed: () =>
                                          formKey.currentState!.validate()
                                          ? _saveHabit(
                                              context: context,
                                              isUpdate: habit != null,
                                              updateHabit: habit,
                                            )
                                          : ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Please give required data',
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is HabitLoading) {
            return const AppLoading();
          } else if (state is HabitError) {
            return ErrorScreenWidget(
              onRetry: () {
                if (habit != null) {
                  context.read<HabitBloc>().add(
                    UpdateHabitInitialEvent(habit: habit!),
                  );
                  nameController.text = habit!.name;
                } else {
                  context.read<HabitBloc>().add(AddHabitInitialEvent());
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _saveHabit({
    required BuildContext context,
    required bool isUpdate,
    required Habit? updateHabit,
  }) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;
    final bloc = context.read<HabitBloc>();
    final state = bloc.state;
    if (state is AddHabitInitial) {
      Habit? habit;
      habit = Habit(
        id: updateHabit?.id ?? DateTime.now().toString(),
        name: nameController.text,
        icon: state.icon,
        color: state.color,
        type: state.habitType,
        goalValue: state.goalValue,
        goalCount: state.goalCount,
        time: state.goalTime,
        endDate: state.isExpanded
            ? HelperFunctions.parseDate(state.endDate)
            : null,
        reminder: state.hasRemainder ? state.remainderTime : null,
        startDate: DateTime.now(),
        goalCompletedCount: updateHabit?.goalCompletedCount ?? 0,
        goalRecordCount: updateHabit?.goalRecordCount ?? 0,
        isCompleteToday: updateHabit?.isCompleteToday ?? false,
        streakCount: updateHabit?.streakCount ?? 0,
        bestStreak: updateHabit?.bestStreak ?? 0,
        countThisMonth: updateHabit?.countThisMonth ?? 0,
        countLastMonth: updateHabit?.countLastMonth ?? 0,
        countThisWeek: updateHabit?.countThisWeek ?? 0,
        countLastWeek: updateHabit?.countLastWeek ?? 0,
        countThisYear: updateHabit?.countThisYear ?? 0,
        countLastYear: updateHabit?.countLastYear ?? 0,
        completedDays: updateHabit?.completedDays ?? [],
        achievements: updateHabit?.achievements ?? {},
      );

      if (habit.goalCount < habit.goalCompletedCount) {
        final reset = await _onResetHabit(context: context);
        if (reset) {
          habit = Habit(
            id: updateHabit?.id ?? DateTime.now().toString(),
            name: nameController.text,
            icon: state.icon,
            color: state.color,
            type: state.habitType,
            goalValue: state.goalValue,
            goalCount: state.goalCount,
            time: state.goalTime,
            endDate: state.isExpanded
                ? HelperFunctions.parseDate(state.endDate)
                : null,
            reminder: state.hasRemainder ? state.remainderTime : null,
            startDate: DateTime.now(),
            goalCompletedCount: 0,
            goalRecordCount: updateHabit?.goalRecordCount ?? 0,
            isCompleteToday: updateHabit?.isCompleteToday ?? false,
            streakCount: updateHabit?.streakCount ?? 0,
            bestStreak: updateHabit?.bestStreak ?? 0,
            countThisMonth: updateHabit?.countThisMonth ?? 0,
            countLastMonth: updateHabit?.countLastMonth ?? 0,
            countThisWeek: updateHabit?.countThisWeek ?? 0,
            countLastWeek: updateHabit?.countLastWeek ?? 0,
            countThisYear: updateHabit?.countThisYear ?? 0,
            countLastYear: updateHabit?.countLastYear ?? 0,
            completedDays: updateHabit?.completedDays ?? [],
            achievements: updateHabit?.achievements ?? {},
          );

          isUpdate
              ? bloc.add(UpdateHabitEvent(habit))
              : bloc.add(AddHabitEvent(habit));
        }
      } else {
        isUpdate
            ? bloc.add(UpdateHabitEvent(habit))
            : bloc.add(AddHabitEvent(habit));
      }
    }
  }

  Future<bool> _onResetHabit({required BuildContext context}) async {
    bool reset = false;
    await showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(Icons.refresh, color: Colors.indigo.shade500),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Text('Reset Goal', style: Theme.of(context).textTheme.titleMedium),
            Text(
              "You have already made progress on this habit.Reducing the goal value will reset your current progress and start the habit again from zero.Do you want to continue?",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          AppButton(
            title: 'Change',
            backgroundColor: Colors.indigo.shade50,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.indigo.shade500),
            onPressed: () => Navigator.pop(context),
            elevation: WidgetStatePropertyAll(0),
          ),
          AppButton(
            title: 'Reset',
            backgroundColor: Colors.red.shade600,
            onPressed: () {
              Navigator.pop(context);
              reset = true;
            },
          ),
        ],
      ),
    );
    return reset;
  }
}

class GoalWidget extends StatelessWidget {
  const GoalWidget({
    super.key,
    required this.backgroundColor,
    required this.isDark,
  });

  final Color backgroundColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final valueCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            GoalValueWidget(
              backgroundColor: backgroundColor,
              formKey: formKey,
              valueCtrl: valueCtrl,
              isDark: isDark,
            ),

            const Divider(color: Colors.black12, height: 0),
            HabitTimeWidget(backgroundColor: backgroundColor),
            const Divider(color: Colors.black12, height: 0),
            HabitEndWidget(backgroundColor: backgroundColor),
          ],
        ),
      ),
    );
  }
}
