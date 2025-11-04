import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/core/components/app_button.dart';

class AppTimePicker extends StatefulWidget {
  final Function(int hour, int minute, String period, DateTime dateTime)
      onTimeSelected;

  const AppTimePicker({
    super.key,
    required this.onTimeSelected,
  });

  @override
  State<AppTimePicker> createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  late int _hour;
  late int _minute;
  late String _period;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    _minute = now.minute;
    _period = now.period == DayPeriod.am ? 'AM' : 'PM';
  }

  DateTime _getSelectedDateTime() {
    final now = DateTime.now();
    int hour24 = _period == 'PM'
        ? (_hour % 12) + 12
        : (_hour % 12); // Convert to 24-hour format
    return DateTime(now.year, now.month, now.day, hour24, _minute);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // Header with title & close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
          
          
              // Time pickers
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour picker
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController:
                            FixedExtentScrollController(initialItem: _hour - 1),
                        onSelectedItemChanged: (index) {
                          setState(() => _hour = index + 1);
                        },
                        children: List.generate(12, (index) {
                          final hour = index + 1;
                          return Center(
                            child: Text(hour.toString().padLeft(2, '0')),
                          );
                        }),
                      ),
                    ),
          
                    // Minute picker
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController:
                            FixedExtentScrollController(initialItem: _minute),
                        onSelectedItemChanged: (index) {
                          setState(() => _minute = index);
                        },
                        children: List.generate(60, (index) {
                          final minute = index;
                          return Center(
                            child: Text(minute.toString().padLeft(2, '0')),
                          );
                        }),
                      ),
                    ),
          
                    // AM/PM picker
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                          initialItem: _period == 'AM' ? 0 : 1,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() => _period = index == 0 ? 'AM' : 'PM');
                        },
                        children: const [
                          Center(child: Text('AM')),
                          Center(child: Text('PM')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          
              // Footer buttons
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: AppButton(
                      title: 'No Time',
                      onPressed: () {
                        widget.onTimeSelected(0, 0, '', DateTime(0));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      title: 'Select',
                      onPressed: () {
                        final dateTime = _getSelectedDateTime();
                        widget.onTimeSelected(_hour, _minute, _period, dateTime);
                        Navigator.pop(context);
                      },
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
}
