import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/functions/habit_complete_func.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_library_screen.dart';
import 'package:pursuit/features/habit/presentation/widgets/body_widget.dart';
import 'package:pursuit/features/habit/presentation/widgets/goals_empty_widget.dart';
import 'package:pursuit/features/habit/presentation/widgets/header_widget.dart';
import 'package:sqflite/sqflite.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool isCompleteToday = false;
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  @override
  void initState() {
    context.read<HabitBloc>().add(GetAllHabitsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            BlocConsumer<HabitBloc, HabitState>(
              buildWhen: (previous, current) {
                if (current is HabitLoading) {
                  return true;
                }
                if (previous is HabitCountUpdateSuccess &&
                    current is HabitCountUpdateSuccess) {
                  return previous.updatedCount != current.updatedCount;
                } else if (current is HabitLoaded) {
                  return true;
                } else if (current is HabitOperationSuccess) {
                  return true;
                }
                return false;
              },
              listener: (context, state) {
                if (state is HabitOperationSuccess) {
                  context.read<HabitBloc>().add(GetAllHabitsEvent());
                }
                if (state is HabitCountUpdateSuccess) {
                  if (state.updatedCount >= state.habit.goalCount &&
                      !state.habit.isCompleteToday) {
                    isCompleteToday = true;
                    final updatedHabit = updateHabitOnCompletion(state.habit);
                    context.read<HabitBloc>().add(
                      UpdateHabitEvent(updatedHabit),
                    );
                  }
                  context.read<HabitBloc>().add(GetAllHabitsEvent());
                }
                if (state is HabitUpdateSuccessState) {
                  context.read<HabitBloc>().add(GetAllHabitsEvent());
                }
              },
              builder: (context, state) {
                if (state is HabitLoading || state is AddHabitInitial) {
                  return const AppLoading();
                } else if (state is HabitLoaded) {
                  final habits = state.habits;
                  if (habits.isEmpty) {
                    return const GoalsEmptyWidget();
                  }
                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          buildHeader(context),
                          buildBody(
                            habits: habits,
                            formKey: _formKey,
                            valueCtrl: _valueCtrl,
                          ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 100,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pursuit your goals',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(color: Colors.black12),
                                  ),
                                  Text(
                                    'Track your growth.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(color: Colors.black12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCompleteToday)
                        IgnorePointer(
                          ignoring: true,
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
                } else if (state is HabitError) {
                  return ErrorScreenWidget(
                    onRetry: () =>
                        context.read<HabitBloc>().add(GetAllHabitsEvent()),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GoalsLibraryScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDatabaseDump(BuildContext context) async {
  final db = await openDatabase('habits.db');
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'",
  );

  final result = <String, dynamic>{};

  for (var t in tables) {
    final tableName = t['name'];
    final rows = await db.query(tableName as String);
    result[tableName] = rows;
  }
  log(result.toString());

  // showDialog(
  //   context: context,
  //   builder: (_) {

  //     return AlertDialog(
  //     title: Text("Database Dump"),
  //     content: SingleChildScrollView(
  //       child: Text(result.toString()),
  //     ),
  //   );},
  // );
}
