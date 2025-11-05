import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';
import 'package:pursuit/features/widgets/time_picker_widget.dart';

class HabitRemainderWidget extends StatelessWidget {
  const HabitRemainderWidget({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is! AddHabitInitial || current is! AddHabitInitial) {
          return false;
        }

        return previous.hasRemainder != current.hasRemainder ||
            previous.remainderTime != current.remainderTime;
      },
      builder: (context, state) {
        if (state is! AddHabitInitial) return const SizedBox.shrink();
        log(state.remainderTime.toString());
        final bool isExpanded = state.hasRemainder;
        final String time = state.remainderTime;

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Remainder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: Switch.adaptive(
                    value: isExpanded,
                    activeThumbColor: backgroundColor,
                    inactiveThumbColor: backgroundColor,
                    trackOutlineColor: WidgetStatePropertyAll(backgroundColor),
                    onChanged: (value) {
                      context.read<HabitBloc>().add(
                        HabitRemainderToggleEvent(hasRemainder: value),
                      );
                    },
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Everyday At'),
                        MyCard(
                          backgroundColor: backgroundColor,
                          value: time.isNotEmpty ? time : 'Add Time',
                          onTap: () => showBottomSheet(
                            showDragHandle: true,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppTimePicker(
                                      onTimeSelected:
                                          (hour, minute, period, dateTime) {
                                            context.read<HabitBloc>().add(
                                              HabitRemainderEvent(
                                                remainderTime:
                                                    hour == 0 && minute == 0
                                                    ? ''
                                                    : "$hour:$minute $period",
                                              ),
                                            );
                                          },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
