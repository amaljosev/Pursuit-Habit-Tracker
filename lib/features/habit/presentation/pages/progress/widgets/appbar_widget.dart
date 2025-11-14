import 'package:flutter/material.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/progress_page.dart';

SliverAppBar buildAppBar(ProgressPage widget) {
  return SliverAppBar(
    expandedHeight: 120,
    backgroundColor: HelperFunctions.getColorById(
      id: widget.habit.color,
      isDark: true,
    ),
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Habit Analytics',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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