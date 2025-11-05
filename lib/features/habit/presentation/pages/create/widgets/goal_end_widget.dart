import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/widgets/date_picker_widget.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';
class HabitEndWidget extends StatelessWidget {
  const HabitEndWidget({super.key, required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is AddHabitInitial && current is AddHabitInitial) {
          return previous.isExpanded != current.isExpanded ||
              previous.endDate != current.endDate;
        }
        return false;
      },
      builder: (context, state) {
        if (state is! AddHabitInitial) {
          return const SizedBox.shrink();
        }

        final bool isExpanded = state.isExpanded;
        final String? endDate = state.endDate;

        return Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: Switch.adaptive(
                  value: isExpanded,
                  activeThumbColor: backgroundColor,
                  inactiveThumbColor: backgroundColor,
                  trackOutlineColor: WidgetStatePropertyAll(backgroundColor),
                  onChanged: (value) {
                    context
                        .read<HabitBloc>()
                        .add(HabitEndDateExpand(isExpand: value));
                  },
                ),
                onTap: () {
                  context
                      .read<HabitBloc>()
                      .add(HabitEndDateExpand(isExpand: !isExpanded));
                },
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
                      Column(
                        spacing: 10,
                        children: [
                          Text(
                            'Start Date',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: Colors.grey),
                          ),
                          MyCard(
                            backgroundColor: backgroundColor,
                            value: 'Today',
                          ),
                        ],
                      ),
                      Column(
                        spacing: 10,
                        children: [
                          Text(
                            'End Date',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: Colors.grey),
                          ),
                          MyCard(
                            backgroundColor: backgroundColor,
                            value: (endDate != null && endDate.isNotEmpty)
                                ? endDate
                                : 'No End',
                            onTap: () => showBottomSheet(
                              showDragHandle: true,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppDatePicker(
                                        onDateSelected: (day, month, year) {
                                          context.read<HabitBloc>().add(
                                                HabitEndDateEvent(
                                                  endDate: day == 0 &&
                                                          month == 0 &&
                                                          year == 0
                                                      ? ''
                                                      : "$day-$month-$year",
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
