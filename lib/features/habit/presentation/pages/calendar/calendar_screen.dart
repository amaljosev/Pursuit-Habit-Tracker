import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/domain/entities/habit.dart';
import 'package:pursuit/features/habit/presentation/blocs/cubit/calendar_cubit.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';
import 'package:pursuit/features/habit/presentation/widgets/number_input_field.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<CalendarCubit>();
    final selected = cubit.state.selectedDate;

    // Load dot indicators for the current month
    cubit.loadMonthStatus(cubit.state.focusedMonth);

    if (selected != null) {
      cubit.refreshDate(selected);
    } else {
      cubit.selectDate(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _CalendarBody();
  }
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) =>
          context.read<HabitBloc>().add(GetAllHabitsEvent()),
      child: BlocConsumer<CalendarCubit, CalendarState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.read<CalendarCubit>().clearError();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : LinearGradient(
                        colors: [primary.withValues(alpha: 0.08), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45],
                      ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── APP BAR ──
                    _AppBar(),

                    // ── CALENDAR CARD ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CalendarCard(state: state),
                    ),

                    const SizedBox(height: 12),

                    // ── SELECTED DATE HEADER ──
                    if (state.selectedDate != null)
                      _SelectedDateHeader(date: state.selectedDate!),

                    // ── HABIT LIST ──
                    Expanded(
                      child: state.selectedDate == null
                          ? _EmptySelection()
                          : _HabitTimeline(state: state),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              CupertinoIcons.chevron_left,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              'History',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
            ),
          ),
          // Spacer to balance back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─── Calendar Card ────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  final CalendarState state;
  const _CalendarCard({required this.state});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cubit = context.read<CalendarCubit>();
    final m = state.focusedMonth;
    final now = DateTime.now();
    final isCurrentMonth = m.year == now.year && m.month == now.month;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.0 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavPill(
                  icon: CupertinoIcons.chevron_left,
                  onTap: cubit.goToPreviousMonth,
                ),
                Column(
                  children: [
                    Text(
                      _months[m.month - 1],
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                    ),
                    Text(
                      '${m.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                _NavPill(
                  icon: CupertinoIcons.chevron_right,
                  disabled: isCurrentMonth,
                  onTap: isCurrentMonth ? null : cubit.goToNextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday labels — Sunday first
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Day grid
            _DayGrid(state: state),

            // ── DOT LEGEND ──
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.green.shade400, label: 'All done'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.orange.shade400, label: 'Partial'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.red.shade400, label: 'Missed'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Day Grid ─────────────────────────────────────────────────────────────────

class _DayGrid extends StatelessWidget {
  final CalendarState state;
  const _DayGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarCubit>();
    final month = state.focusedMonth;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    final firstDay = DateTime(month.year, month.month, 1);
    // Sunday-based: weekday%7 → Sun=0, Mon=1 … Sat=6
    final startOffset = firstDay.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final rows = ((startOffset + daysInMonth) / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            final day = idx - startOffset + 1;

            if (day < 1 || day > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(month.year, month.month, day);
            final isFuture = date.isAfter(todayNorm);
            final isToday = date == todayNorm;
            final isSelected = state.selectedDate != null &&
                _sameDay(date, state.selectedDate!);

            // Look up dot status
            final key =
                '${date.year.toString().padLeft(4, '0')}-'
                '${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}';
            final dotStatus = state.monthDayStatus[key] ?? '';

            return Expanded(
              child: GestureDetector(
                onTap: isFuture ? null : () => cubit.selectDate(date),
                child: _DayCell(
                  day: day,
                  isToday: isToday,
                  isSelected: isSelected,
                  isFuture: isFuture,
                  dotStatus: dotStatus,
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final String dotStatus;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.dotStatus,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg = Colors.transparent;
    Color fg = isDark ? Colors.white : Colors.black87;
    Border? border;

    if (isSelected) {
      bg = primary;
      fg = Colors.white;
    } else if (isToday) {
      bg = primary.withValues(alpha: 0.12);
      border = Border.all(color: primary, width: 1.5);
    } else if (isFuture) {
      fg = Colors.grey.shade400;
    }

    // Dot color — hidden when day is selected (bg already communicates state)
    final Color? dotColor = isSelected || dotStatus.isEmpty
        ? null
        : dotStatus == 'done'
            ? Colors.green.shade400
            : dotStatus == 'partial'
                ? Colors.orange.shade400
                : Colors.red.shade400; // missed

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(2.5),
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight:
                  isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          // Always reserve dot space to keep cell height stable
          dotColor != null
              ? Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox(width: 5, height: 5),
        ],
      ),
    );
  }
}

// ─── Selected Date Header ─────────────────────────────────────────────────────

class _SelectedDateHeader extends StatelessWidget {
  final DateTime date;
  const _SelectedDateHeader({required this.date});

  static const _weekdays = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date ==
        DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));

    final String title;
    if (isToday) {
      title = 'Today';
    } else if (isYesterday) {
      title = 'Yesterday';
    } else {
      title = _weekdays[date.weekday];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            '${_months[date.month]} ${date.day}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty selection ──────────────────────────────────────────────────────────

class _EmptySelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.calendar, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Tap a date to view habits',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Habit Timeline List ──────────────────────────────────────────────────────

class _HabitTimeline extends StatelessWidget {
  final CalendarState state;
  const _HabitTimeline({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingDay) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (state.habitsForDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.moon_zzz,
              size: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              'No habits on this day',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final date = state.selectedDate!;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: state.habitsForDate.length,
      itemBuilder: (context, index) {
        final habit = state.habitsForDate[index];
        final isLast = index == state.habitsForDate.length - 1;
        return _TimelineItem(habit: habit, date: date, isLast: isLast);
      },
    );
  }
}

// ─── Timeline Item ────────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final Habit habit;
  final DateTime date;
  final bool isLast;

  const _TimelineItem({
    required this.habit,
    required this.date,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = habit.isCompletedOnDate(date);
    final count = habit.getCountForDate(date);
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final dateNorm = DateTime(date.year, date.month, date.day);
    final isPast = dateNorm.isBefore(todayNorm);

    final color = HelperFunctions.getColorById(id: habit.color, isDark: true);
    final emoji = HelperFunctions.getEmojiById(habit.icon);
    final measureLabel = HelperFunctions.getMeasureById(habit.goalValue);

    // Status
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;
    if (isCompleted) {
      statusColor = color;
      statusLabel = 'Done';
      statusIcon = CupertinoIcons.checkmark_alt_circle_fill;
    } else if (isPast) {
      statusColor = Colors.red.shade400;
      statusLabel = 'Missed';
      statusIcon = CupertinoIcons.xmark_circle_fill;
    } else {
      statusColor = Colors.orange.shade400;
      statusLabel = 'Pending';
      statusIcon = CupertinoIcons.clock_fill;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TIMELINE SPINE ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? color
                        : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isCompleted ? color : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── HABIT CARD ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _openEditSheet(
                  context,
                  isCompleted,
                  count,
                  color,
                  emoji,
                  measureLabel,
                  isDark,
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? color.withValues(alpha: 0.10)
                        : color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? color.withValues(alpha: 0.35)
                          : isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Emoji avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name + progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Colors.grey.shade400,
                                    color: isCompleted
                                        ? Colors.grey.shade500
                                        : null,
                                  ),
                            ),
                            if (habit.goalCount > 1) ...[
                              const SizedBox(height: 6),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      (count / habit.goalCount).clamp(0.0, 1.0),
                                  minHeight: 5,
                                  backgroundColor:
                                      color.withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation(color),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count / ${habit.goalCount} $measureLabel',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status badge
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 20),
                          const SizedBox(height: 3),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    bool isCompleted,
    int currentCount,
    Color color,
    String emoji,
    String measureLabel,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CalendarCubit>(),
        child: _HabitEditSheet(
          habit: habit,
          date: date,
          color: color,
          emoji: emoji,
          measureLabel: measureLabel,
          isDark: isDark,
          initialCount: currentCount,
          isCompleted: isCompleted,
        ),
      ),
    );
  }
}

// ─── Habit Edit Bottom Sheet ───────────────────────────────────────────────────

class _HabitEditSheet extends StatefulWidget {
  final Habit habit;
  final DateTime date;
  final Color color;
  final String emoji;
  final String measureLabel;
  final bool isDark;
  final int initialCount;
  final bool isCompleted;

  const _HabitEditSheet({
    required this.habit,
    required this.date,
    required this.color,
    required this.emoji,
    required this.measureLabel,
    required this.isDark,
    required this.initialCount,
    required this.isCompleted,
  });

  @override
  State<_HabitEditSheet> createState() => _HabitEditSheetState();
}

class _HabitEditSheetState extends State<_HabitEditSheet> {
  late int _count;
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    context.read<CalendarCubit>().toggleHabitOnDate(
          habitId: widget.habit.id,
          date: widget.date,
          markCompleted: _count >= widget.habit.goalCount,
          count: _count,
        );
    Navigator.pop(context);
  }

  Future<void> _openNumberInput() async {
    _ctrl.text = _count > 0 ? _count.toString() : '1';
    final result = await numberInputField(
      context: context,
      formKey: _formKey,
      controller: _ctrl,
      backgroundColor: widget.color,
      isDarkMode: widget.isDark,
      goalCount: widget.habit.goalCount,
    );
    if (result != null && result.isNotEmpty) {
      final val = int.tryParse(result);
      if (val != null && mounted) {
        setState(() => _count = val.clamp(0, widget.habit.goalCount));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final color = widget.color;
    final isDark = widget.isDark;
    final progress =
        habit.goalCount > 0 ? (_count / habit.goalCount).clamp(0.0, 1.0) : 0.0;

    // Date label
    final now = DateTime.now();
    final todayNorm = DateTime(now.year, now.month, now.day);
    final dateNorm = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    final String dateLabel;
    if (dateNorm == todayNorm) {
      dateLabel = 'Today';
    } else if (dateNorm == todayNorm.subtract(const Duration(days: 1))) {
      dateLabel = 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateLabel =
          '${months[widget.date.month - 1]} ${widget.date.day}, ${widget.date.year}';
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).bottomSheetTheme.backgroundColor
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar + count
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.toDouble()),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_count / ${habit.goalCount} ${widget.measureLabel}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                ),
                GestureDetector(
                  onTap: _openNumberInput,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.pencil, size: 13, color: color),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // +1 / -1 quick buttons
            Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    label: '−1',
                    sublabel: widget.measureLabel,
                    color: color,
                    isDark: isDark,
                    enabled: _count > 0,
                    onTap: () => setState(() => _count--),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickButton(
                    label: '+1',
                    sublabel: widget.measureLabel,
                    color: color,
                    isDark: isDark,
                    enabled: _count < habit.goalCount,
                    onTap: () => setState(() => _count++),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Clear / Finish
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _count == 0 ? null : () => setState(() => _count = 0),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _count >= habit.goalCount
                        ? null
                        : () => setState(() => _count = habit.goalCount),
                    icon: const Icon(CupertinoIcons.check_mark, size: 16),
                    label: const Text('Finish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: color.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick +1 / -1 Button ─────────────────────────────────────────────────────

class _QuickButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  const _QuickButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isDark,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.25)
                : Colors.grey.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: enabled ? color : Colors.grey.shade400,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: enabled
                    ? color.withValues(alpha: 0.7)
                    : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Pill ─────────────────────────────────────────────────────────────────

class _NavPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _NavPill({required this.icon, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.withValues(alpha: 0.08)
              : primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: disabled ? Colors.grey.shade400 : primary,
        ),
      ),
    );
  }
}