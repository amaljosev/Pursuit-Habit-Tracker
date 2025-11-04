import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.habit});
  final Habit habit;
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
        builder: (context, state) {
          if (state is HabitError) {
            return const ErrorScreenWidget();
          }
          if (state is HabitLoading) {
            return const AppLoading();
          }
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
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) => false,
                      ),
                    ),
                    title: Text(habit.name),
                    actions: [
                      PopupMenuButton<String>(
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
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            value: 'delete',
                            child: const Row(
                              children: [
                                Expanded(child: Text('Delete')),
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (String value) {
                          if (value == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddHabitScreen(habit: habit),
                              ),
                            );
                          } else if (value == 'delete') {
                            onDeleteHabit(context: context, id: habit.id);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyCard(
                        backgroundColor: HelperFunctions.getColorById(
                          id: habit.color,
                        ),
                        value: HelperFunctions.getTypeById(habit.type),
                      ),
                    ],
                  ),
                  Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.01,
                        strokeWidth: 20.0,
                        color: HelperFunctions.getColorById(
                          id: habit.color,
                          isDark: true,
                        ),
                        constraints: BoxConstraints(
                          maxHeight: 300,
                          maxWidth: 300,
                          minHeight: 300,
                          minWidth: 300,
                        ),
                        backgroundColor: Colors.white,
                        year2023: false,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 20,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.remove),
                              ),
                              Text(
                                HelperFunctions.getEmojiById(habit.icon),
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add),
                              ),
                            ],
                          ),
                          Text(
                            "${habit.goalCompletedCount} ${HelperFunctions.getMeasureById(habit.goalValue)} / ${habit.goalCount} ${HelperFunctions.getMeasureById(habit.goalValue)}",
                          ),
                        ],
                      ),
                    ],
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
        },
      ),
    );
  }
}
