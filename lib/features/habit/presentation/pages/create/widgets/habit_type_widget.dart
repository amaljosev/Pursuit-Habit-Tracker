import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/constants/habit_types.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

class HabitTypeWidget extends StatelessWidget {
  const HabitTypeWidget({super.key, required this.bgColor});
  final int bgColor;
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
              child: DefaultTabController(
                initialIndex: state.habitType,
                length: HabitTypes.types.length,
                child: Builder(
                  builder: (context) {
                    final TabController controller = DefaultTabController.of(
                      context,
                    );

                    // Listen for tab index changes
                    controller.addListener(() {
                      if (!controller.indexIsChanging) {
                        context.read<HabitBloc>().add(
                          HabitTypeEvent(habitType: controller.index),
                        );
                      }
                    });

                    return Column(
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
                            color: AppColors.darkColors[bgColor]['color']
                                .withValues(alpha: 0.3),
                          ),
                          child: SizedBox(
                            height: 30,
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: AppColors.darkColors[bgColor]['color'],
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
                    );
                  },
                ),
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
