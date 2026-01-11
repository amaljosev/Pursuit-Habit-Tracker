import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/core/components/loading_widget.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';
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
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (context) => AddHabitScreen()),
                // );
                //  showDatabaseDump(context);
                //  Navigator.of(context).pushNamed('/add');
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
