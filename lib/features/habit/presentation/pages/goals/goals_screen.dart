
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/components/error_widget.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/widgets/body_widget.dart';
import 'package:pursuit/features/habit/presentation/widgets/goals_empty_widget.dart';
import 'package:pursuit/features/habit/presentation/widgets/header_widget.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    context.read<HabitBloc>().add(GetAllHabitsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          BlocConsumer<HabitBloc, HabitState>(
            listener: (context, state) {
              if (state is HabitOperationSuccess) {
                context.read<HabitBloc>().add(GetAllHabitsEvent());
              }
            },
            builder: (context, state) {
              if (state is HabitLoading ||
                  state is AddHabitInitial ||
                  state is HabitDetailLoaded) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HabitLoaded) {
                final habits = state.habits;
                if (habits.isEmpty) {
                  return const GoalsEmptyWidget();
                }
                return CustomScrollView(
                  slivers: [buildHeader(size, context), buildBody(habits)],
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
              Navigator.of(context).pushNamed('/add');
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
