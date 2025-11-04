import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/constants/habit_timings.dart';
import 'package:pursuit/features/habit/presentation/blocs/bloc/habit_bloc.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

class HabitTimeWidget extends StatelessWidget {
  const HabitTimeWidget({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is AddHabitInitial && current is AddHabitInitial) {
          return previous.goalTime != current.goalTime;
        }
        return true; 
      },
      builder: (context, state) {
        log('goal time rebuild');
        if (state is AddHabitInitial) {
          return Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),

            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(0),
              leading: Text(
                'Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              trailing: CupertinoListTileChevron(),

              childrenPadding: const EdgeInsets.symmetric(vertical: 10),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    HabitTimings.times[state.goalTime]['name'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(HabitTimings.times.length, (index) {
                    final time = HabitTimings.times[index]['name'];
                    final id = HabitTimings.times[index]['id'];
                    return MyCard(
                      backgroundColor: backgroundColor,
                      value: time,
                      onTap: id == state.goalTime
                          ? null
                          : () {
                              context.read<HabitBloc>().add(
                                HabitGoalTimeEvent(goalTime: id),
                              );
                            },
                    );
                  }),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
