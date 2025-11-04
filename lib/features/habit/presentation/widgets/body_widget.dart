import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/goal_detail_screen.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';

SliverList buildBody(List<Habit> habits) {
  return SliverList.builder(
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ProgressTile(habit: habits[index]),
    ),

    itemCount: habits.length,
  );
}

class ProgressTile extends StatelessWidget {
  final Habit habit;

  const ProgressTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final double progress = (habit.goalCount > 0)
        ? habit.goalCompletedCount / habit.goalCount
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: HelperFunctions.getColorById(
          id: habit.color,
        ).withValues(alpha: 0.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,

              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: HelperFunctions.getColorById(id: habit.color),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Foreground content
          Slidable(
            endActionPane: ActionPane(
              extentRatio: 0.2,
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  onPressed: (context) =>
                      onDeleteHabit(context: context, id: habit.id),
                  backgroundColor: AppColors.error,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.transparent,
              leading: SizedBox(
                height: 45,
                width: 45,
                child: Center(
                  child: Text(
                    HelperFunctions.getEmojiById(habit.icon),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
              title: Text(
                habit.name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${habit.goalCompletedCount} of ${habit.goalCount} completed",
              ),
              subtitleTextStyle: Theme.of(context).textTheme.titleSmall,
              trailing: Icon(Icons.circle_outlined, color: Colors.grey[700]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalDetailScreen(habit: habit),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
