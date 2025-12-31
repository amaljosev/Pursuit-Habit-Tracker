import 'package:flutter/material.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/presentation/pages/progress/progress_page.dart';

SliverToBoxAdapter buildStatsOverview(
  BuildContext context,
  Animation<double> fadeAnimation,
  ProgressPage widget,
) {
  return SliverToBoxAdapter(
    child: FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main Stats Row
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem(
                  '🔥',
                  'Current Streak',
                  '${widget.habit.streakCount} days',
                  widget,
                ),
                _buildStatItem(
                  '⭐',
                  'Best Streak',
                  '${widget.habit.bestStreak} days',
                  widget,
                ),
                _buildStatItem(
                  '📈',
                  'Completion',
                  '${calculateCompletionRate(widget)}%',
                  widget,
                ),
              ],
            ),
            SizedBox(height: 20),

            // Comparative Periods
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Progress Comparison',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    children: [
                      _buildComparisonCard(
                        'This Week',
                        widget.habit.countThisWeek,
                        'Last Week',
                        widget.habit.countLastWeek,
                        widget,
                        context,
                      ),
                      SizedBox(width: 12),
                      _buildComparisonCard(
                        'This Month',
                        widget.habit.countThisMonth,
                        'Last Month',
                        widget.habit.countLastMonth,
                        widget,
                        context,
                      ),
                      SizedBox(width: 12),
                      _buildComparisonCard(
                        'This Year',
                        widget.habit.countThisYear,
                        'Last Year',
                        widget.habit.countLastYear,
                        widget,
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildComparisonCard(
  String currentLabel,
  int currentValue,
  String previousLabel,
  int previousValue,
  ProgressPage widget,
  BuildContext context,
) {
  final bool isIncrease = currentValue >= previousValue;
  final habitColor = HelperFunctions.getColorById(id: widget.habit.color);

  return Container(
    width: context.screenWidth > 760
        ? context.screenWidth * 0.25
        : context.screenWidth * 0.5,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentLabel,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$currentValue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: habitColor,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isIncrease ? Colors.green : Colors.red,
            ),
            SizedBox(width: 4),
            Text(
              previousLabel,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        Text(
          '$previousValue',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatItem(
  String emoji,
  String label,
  String value,
  ProgressPage widget,
) {
  return Column(
    children: [
      CircleAvatar(
        backgroundColor: HelperFunctions.getColorById(
          id: widget.habit.color,
        ).withValues(alpha: 0.5),
        child: Text(emoji, style: TextStyle(fontSize: 24)),
      ),
      SizedBox(height: 8),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );
}

int calculateCompletionRate(ProgressPage widget) {
  if (widget.habit.goalCount == 0) return 0;
  return ((widget.habit.goalCompletedCount / widget.habit.goalCount) * 100)
      .round();
}
