import 'package:flutter/material.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/progress_page.dart';

SliverAppBar buildAppBar(
  ProgressPage widget,
  bool isDark,
  BuildContext context,
) {
  return SliverAppBar(
    expandedHeight: 120,
    backgroundColor: isDark
        ? null
        : HelperFunctions.getColorById(id: widget.habit.color, isDark: true),
    pinned: true,

    foregroundColor: Colors.white,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: Text(
        'Habit Analytics',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Colors.white
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HelperFunctions.getColorById(
                      id: widget.habit.color,
                    ).withOpacity(0.3),
                    HelperFunctions.getColorById(id: widget.habit.color),
                  ],
                ),
        ),
      ),
    ),
  );
}
