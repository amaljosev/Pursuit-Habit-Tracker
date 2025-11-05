import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
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
import 'package:pursuit/features/widgets/my_card_widget.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key, this.habit});
  final Habit? habit;
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
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
    return PopScope(
      canPop: false,
      child: _HabitView(
        nameController: nameController,
        formKey: formKey,
        habit: widget.habit,
      ),
    );
  }
}

class _HabitView extends StatelessWidget {
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final Habit? habit;
  const _HabitView({
    required this.nameController,
    required this.formKey,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitOperationSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
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
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: SafeArea(
                    child: Form(
                      key: formKey,
                      child: Column(
                        spacing: 10,
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
                            actions: [
                              MyCard(
                                backgroundColor: backgroundColorDark,
                                value: habit != null ? 'Update' : 'Save',
                                onTap: () => formKey.currentState!.validate()
                                    ? _saveHabit(context)
                                    : ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please give required data',
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          IconPickerWidget(),
                          InputFieldWidget(
                            controller: nameController,
                            color: backgroundColorDark,
                            formKey: formKey,
                          ),
                          const ColorPickerWidget(),
                          HabitTypeWidget(bgColor: state.color),
                          GoalWidget(backgroundColor: backgroundColorDark),
                          HabitRemainderWidget(
                            backgroundColor: backgroundColorDark,
                          ),
                          SizedBox(
                            width: 200,
                            child: AppButton(
                              title: habit != null ? 'Update' : 'Save',
                              backgroundColor: backgroundColorDark,
                              onPressed: () => formKey.currentState!.validate()
                                  ? _saveHabit(context)
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please give required data',
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (state is HabitLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HabitError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _saveHabit(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final bloc = context.read<HabitBloc>();
    final state = bloc.state;

    if (state is AddHabitInitial) {
      final habit = Habit(
        id: DateTime.now().toString(),
        name: nameController.text,
        icon: state.icon,
        color: state.color,
        type: state.habitType,
        goalValue: state.goalValue,
        goalCount: state.goalCount,
        time: state.goalTime,
        endDate: HelperFunctions.parseDate(state.endDate),
        reminder: state.remainderTime,
        startDate: DateTime.now(),
        goalCompletedCount: 0,
        goalRecordCount: 0,
        isCompleteToday: false,
        streakCount: 0,
        bestStreak: 0,
        countThisMonth: 0,
        countLastMonth: 0,
        countThisWeek: 0,
        countLastWeek: 0,
        countThisYear: 0,
        countLastYear: 0,
        completedDays: [],
        achievements: {},
      );

      bloc.add(AddHabitEvent(habit));
    }
  }
}

class GoalWidget extends StatelessWidget {
  const GoalWidget({super.key, required this.backgroundColor});

  final Color backgroundColor;

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
