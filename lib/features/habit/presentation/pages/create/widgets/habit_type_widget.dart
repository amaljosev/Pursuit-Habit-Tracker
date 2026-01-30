import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_types.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

class HabitTypeWidget extends StatefulWidget {
  const HabitTypeWidget({super.key, required this.bgColor});
  final int bgColor;
  
  @override
  State<HabitTypeWidget> createState() => _HabitTypeWidgetState();
}

class _HabitTypeWidgetState extends State<HabitTypeWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with current state value
    final state = context.read<HabitBloc>().state;
    if (state is AddHabitInitial) {
      _tabController = TabController(
        length: HabitTypes.types.length,
        vsync: this,
        initialIndex: state.habitType == 5 ? 1 : 0,
      );
      
      // Add listener after initialization
      _tabController.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<HabitBloc>().add(
        HabitTypeEvent(habitType: _tabController.index),
      );
    }
  }

  @override
  void didUpdateWidget(HabitTypeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab controller index when state changes
    final state = context.read<HabitBloc>().state;
    if (state is AddHabitInitial && 
        _tabController.index != (state.habitType == 5 ? 1 : 0)) {
      _tabController.animateTo(state.habitType == 5 ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is AddHabitInitial && current is AddHabitInitial) {
          return previous.habitType != current.habitType;
        }
        return false;
      },
      builder: (context, state) {
        if (state is AddHabitInitial) {
          return Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    'Habit Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black12
                          : AppColors.darkColors[widget.bgColor]['color']
                              .withValues(alpha: 0.3),
                    ),
                    child: SizedBox(
                      height: 30,
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.darkColors[widget.bgColor]['color'],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        tabs: List.generate(
                          HabitTypes.types.length,
                          (index) =>
                              Tab(text: HabitTypes.types[index]['name']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}