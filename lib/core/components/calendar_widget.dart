import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderWidget extends StatelessWidget {
  const CalenderWidget({
    super.key,
    this.isHome = false,
    this.rangeEndDay,
    this.showHeader = false,
    this.onDaySelected,
    this.onDisabled,
  });
  final bool isHome;
  final DateTime? rangeEndDay;
  final bool showHeader;
  final void Function(DateTime, DateTime)? onDaySelected;
  final void Function(DateTime)? onDisabled;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime.now(),
      lastDay: DateTime.utc(2060, 10, 16),
      calendarFormat: isHome ? CalendarFormat.week : CalendarFormat.month,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
        weekendStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
      ),
      headerVisible: showHeader,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
      onDaySelected: onDaySelected,
      onDisabledDayTapped: onDisabled,
    );
  }
}

class HabitAnalyticsCalendarWidget extends StatelessWidget {
  final DateTime? rangeStartDay;
  final DateTime? rangeEndDay;
  final bool showHeader;
  final void Function(DateTime, DateTime)? onDaySelected;
  final void Function(DateTime)? onDisabled;

  const HabitAnalyticsCalendarWidget({
    super.key,
    this.rangeStartDay,
    this.rangeEndDay,
    this.showHeader = false,
    this.onDaySelected,
    this.onDisabled,
  });

  // Modern pastel and vibrant color palette
  static const Color rangeColor = Color(0xFFFF70A6); // Vibrant pink
  static const Color highlightColor = Color(0xFF70D6FF); // Neon blue
  static const Color todayColor = Color(0xFFF4D44E); // Lemon yellow
  static const Color backgroundColor = Color(0xFFF5F7FA); // Soft off-white

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2060, 10, 16),
        calendarFormat: CalendarFormat.month,
        rangeStartDay: rangeStartDay,
        rangeEndDay: rangeEndDay,
        rangeSelectionMode: RangeSelectionMode.toggledOn,
        headerVisible: showHeader,

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.bodyLarge!,
          headerPadding: const EdgeInsets.all(0)
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          weekendStyle: TextStyle(
            color: rangeColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: todayColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: rangeColor,
            shape: BoxShape.circle,
          ),
          rangeStartDecoration: BoxDecoration(
            color: rangeColor,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: rangeColor,
            shape: BoxShape.circle,
          ),
          withinRangeDecoration: BoxDecoration(
            color: rangeColor.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          rangeHighlightColor: rangeColor.withValues(alpha: 0.20),
          outsideDaysVisible: false,
          
        ),

        // calendarBuilders: CalendarBuilders(
        //   rangeHighlightBuilder: (context, day, isWithinRange) {
        //     if (isWithinRange) {
        //       return Container(
        //         margin: const EdgeInsets.all(6),
        //         decoration: BoxDecoration(
        //           color: highlightColor.withValues(alpha: 0.13),
        //           shape: BoxShape.circle,
        //         ),
        //         child: Center(
        //           child: Text('${day.day}', style: TextStyle(color: textColor)),
        //         ),
        //       );
        //     }
        //     return null;
        //   },
        // ),
        // selectedDayPredicate: (day) =>
        //     (rangeStartDay != null &&
        //         rangeEndDay == null &&
        //         isSameDay(day, rangeStartDay!)) ||
        //     (rangeStartDay != null &&
        //         rangeEndDay != null &&
        //         (isSameDay(day, rangeStartDay!) ||
        //             isSameDay(day, rangeEndDay!))),
        // onDaySelected: (selectedDay, focusedDay) {
        //   if (onDaySelected != null && rangeStartDay != null) {
        //     onDaySelected!(selectedDay, rangeStartDay!);
        //   }
        // },
        onDisabledDayTapped: onDisabled,
      ),
    );
  }
}

