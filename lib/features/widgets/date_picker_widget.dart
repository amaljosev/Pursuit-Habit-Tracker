import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/core/components/app_button.dart';

class AppDatePicker extends StatefulWidget {
  final Function(int day, int month, int year) onDateSelected;

  const AppDatePicker({super.key, required this.onDateSelected});

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().add(const Duration(days: 1));
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  minimumDate: DateTime.now().add(const Duration(days: 1)),
                  initialDateTime: DateTime.now().add(const Duration(days: 1)),
                  maximumYear: DateTime.now().year + 5,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  },
                ),
              ),

              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: AppButton(
                      title: 'No End',
                      onPressed: () {
                        widget.onDateSelected(0, 0, 0);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      title: 'Select',
                      onPressed: () {
                        widget.onDateSelected(
                          selectedDate.day,
                          selectedDate.month,
                          selectedDate.year,
                        );
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
