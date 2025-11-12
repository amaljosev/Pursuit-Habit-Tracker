import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/goal_detail_screen.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';

SliverList buildBody({
  required List<Habit> habits,
  required GlobalKey<FormState> formKey,
  required TextEditingController valueCtrl,
}) {
  return SliverList.builder(
    itemBuilder: (context, index) => Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ProgressTile(
        habit: habits[index],
        formKey: formKey,
        valueCtrl: valueCtrl,
      ),
    ),

    itemCount: habits.length,
  );
}

class ProgressTile extends StatelessWidget {
  final Habit habit;
  final GlobalKey<FormState> formKey;
  final TextEditingController valueCtrl;

  const ProgressTile({
    super.key,
    required this.habit,
    required this.formKey,
    required this.valueCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (habit.goalCount > 0)
        ? (habit.goalCompletedCount / habit.goalCount).clamp(0.0, 1.0)
        : 0.0;

    final baseColor = HelperFunctions.getColorById(id: habit.color);

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Animated progress background
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: IntrinsicHeight(
                    child: Container(
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          /// Foreground content
          Slidable(
            endActionPane: ActionPane(
              extentRatio: 0.2,
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(12),
                  onPressed: (context) =>
                      onDeleteHabit(context: context, id: habit.id),
                  backgroundColor: AppColors.error,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: HabitTile(
              habit: habit,
              progress: progress,
              baseColor: baseColor,
              valueCtrl: valueCtrl,
              formKey: formKey,
              onDeleteHabit: onDeleteHabit,
            ),
          ),
        ],
      ),
    );
  }
}

class HabitTile extends StatefulWidget {
  final Habit habit;
  final double progress;
  final Color baseColor;
  final TextEditingController valueCtrl;
  final GlobalKey<FormState> formKey;
  final Function onDeleteHabit;

  const HabitTile({
    super.key,
    required this.habit,
    required this.progress,
    required this.baseColor,
    required this.valueCtrl,
    required this.formKey,
    required this.onDeleteHabit,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  final GlobalKey _tileKey = GlobalKey();
  double _tileHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    final box = _tileKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      setState(() => _tileHeight = box.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final progress = widget.progress;
    final baseColor = widget.baseColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        /// Animated background progress bar
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: _tileHeight == 0 ? null : _tileHeight,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),

        /// Foreground content
        Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.2,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                borderRadius: BorderRadius.circular(12),
                onPressed: (context) =>
                    widget.onDeleteHabit(context: context, id: habit.id),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            key: _tileKey, 
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
              habit.goalCompletedCount >= habit.goalCount
                  ? 'Today’s goal achieved'
                  : "${habit.goalCompletedCount} of ${habit.goalCount} completed",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: habit.goalCompletedCount >= habit.goalCount
                  ? Image.asset(
                      'assets/img/success_home.png',
                      height: 40,
                      width: 40,
                    )
                  : GestureDetector(
                      onTap: () async {
                        widget.valueCtrl.text = habit.goalCount > 2
                            ? (habit.goalCount - 2).toString()
                            : '1';
                        final result = await numberInputField(
                          context: context,
                          formKey: widget.formKey,
                          controller: widget.valueCtrl,
                          backgroundColor: HelperFunctions.getColorById(
                            id: habit.color,
                            isDark: true,
                          ),
                          goalCount: habit.goalCount,
                        );
                        if (result != null && result.isNotEmpty) {
                          if (context.mounted) {
                            final int val = int.parse(result);
                            context.read<HabitBloc>().add(
                              GoalCountUpdateEvent(
                                id: habit.id,
                                value: habit.goalCompletedCount + val,
                              ),
                            );
                          }
                        }
                      },
                      child: Icon(
                        Icons.add_circle_outline_sharp,
                        size: 30,
                        color: HelperFunctions.getColorById(
                          id: habit.color,
                          isDark: true,
                        ),
                      ),
                    ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalDetailScreen(habitId: habit.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
