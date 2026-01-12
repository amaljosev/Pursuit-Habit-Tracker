import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/pages/detail/goal_detail_screen.dart';
import 'package:pursuit/features/habit/presentation/widgets/delete_habit.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';

String heroTagForHabit(String habitId) => 'habit-hero-$habitId';

SliverList buildBody({
  required List<Habit> habits,
  required GlobalKey<FormState> formKey,
  required TextEditingController valueCtrl,
}) {
  return SliverList.builder(
    itemBuilder: (context, index) {
      final Habit habit = habits[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: HabitTile(habit: habit, valueCtrl: valueCtrl, formKey: formKey),
      );
    },

    itemCount: habits.length,
  );
}

class HabitTile extends StatefulWidget {
  final Habit habit;
  final TextEditingController valueCtrl;
  final GlobalKey<FormState> formKey;

  const HabitTile({
    super.key,
    required this.habit,

    required this.valueCtrl,
    required this.formKey,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final habit = widget.habit;
    final double progress = (habit.goalCount > 0)
        ? (habit.goalCompletedCount / habit.goalCount).clamp(0.0, 1.0)
        : 0.0;

    final baseColor = HelperFunctions.getColorById(
      id: habit.color,
      isDark: isDarkMode,
    );

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
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
            key: ValueKey(habit.id),
            closeOnScroll: true,

            endActionPane: ActionPane(
              extentRatio: progress == 1.0 ? 0.2 : 0.4,
              motion: const DrawerMotion(),

              children: [
                SlidableAction(
                  flex: 10,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: (context) => onDeleteHabit(
                    context: context,
                    id: habit.id,
                    fromHome: true,
                  ),
                  backgroundColor: Colors.red,
                  icon: Platform.isAndroid
                      ? Icons.delete
                      : CupertinoIcons.delete,
                  label: 'Delete',
                ),
                if (progress != 1.0) Flexible(flex: 1, child: SizedBox()),
                if (progress != 1.0)
                  SlidableAction(
                    flex: 10,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: (context) => context.read<HabitBloc>().add(
                      GoalCountUpdateEvent(
                        id: habit.id,
                        value: habit.goalCount,
                        habit: habit,
                      ),
                    ),
                    backgroundColor: HelperFunctions.getColorById(
                      id: habit.color,
                      isDark: true,
                    ),
                    icon: Platform.isAndroid
                        ? Icons.check
                        : CupertinoIcons.check_mark,
                    label: 'Finish',
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
                  child: Hero(
                    tag: habit.id,
                    child: Text(
                      HelperFunctions.getEmojiById(habit.icon),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ),
              ),
              title: Text(
                habit.name,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: habit.color == 12 && progress > 0.2
                      ? Colors.black
                      : null,
                ),
              ),
              subtitle: Text(
                habit.goalCompletedCount >= habit.goalCount
                    ? 'Today’s goal achieved'
                    : "${habit.goalCompletedCount} of ${habit.goalCount} completed",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: habit.color == 12 && progress > 0.2
                      ? Colors.black
                      : null,
                ),
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
                          isDarkMode: isDarkMode,
                          goalCount: habit.goalCount,
                        );
                        if (result != null && result.isNotEmpty) {
                          if (context.mounted) {
                            final int val = int.parse(result);
                            context.read<HabitBloc>().add(
                              GoalCountUpdateEvent(
                                id: habit.id,
                                value: habit.goalCompletedCount + val,
                                habit: habit,
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
                    builder: (context) => GoalDetailScreen(
                      habitId: habit.id,
                      habitIcon: HelperFunctions.getEmojiById(habit.icon),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
