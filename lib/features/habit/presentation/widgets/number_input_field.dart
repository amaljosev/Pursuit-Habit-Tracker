import 'package:flutter/material.dart';
import 'package:pursuit/core/components/app_button.dart';
import 'package:pursuit/features/widgets/my_card_widget.dart';

Future<dynamic> numberInputField({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController controller,
  required Color backgroundColor,
  required bool isDarkMode,
  int? goalCount,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final List items = getDefaultGoalValues(goalCount ?? 0);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enter value (Count)",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (items.length > 1)
                Wrap(
                  spacing: 10,
                  runAlignment: WrapAlignment.center,
                  runSpacing: 10,
                  children: List.generate(
                    items.length,
                    (index) => MyCard(
                      onTap: () => controller.text = items[index].toString(),
                      backgroundColor: backgroundColor,
                      value: items[index].toString(),
                    ),
                  ),
                ),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: "eg: 20",
                  filled: true,
                  fillColor:isDarkMode? backgroundColor.withValues(alpha: 0.1): backgroundColor.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a count';
                  }
                  final numberRegex = RegExp(r'^\d*\.?\d+$');
                  if (!numberRegex.hasMatch(value.trim())) {
                    return 'Enter a valid number';
                  }
                  final number = double.parse(value);
                  if (number < 1) {
                    return 'Minimum 1 is required';
                  }

                  if (value.length > 5) {
                    return 'Number is too long';
                  }
                  

                  return null;
                },
                onFieldSubmitted: (value) {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, value);
                  }
                },
              ),
              SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        backgroundColor: backgroundColor,
                        title: 'Save',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context, controller.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<int> getDefaultGoalValues(int goalCount) {
  if (goalCount <= 1) return [1];

  // Choose a "nice" step based on the scale of goalCount
  int step = _getStepSize(goalCount);

  // Generate values dynamically
  List<int> values = [];
  for (int i = step; i < goalCount; i += step) {
    values.add(i);
  }

  // Ensure last value is close to but less than goalCount
  if (values.isEmpty || values.last < goalCount - step ~/ 2) {
    values.add(goalCount - step);
  }

  // Remove any invalid or duplicate values
  values = values.toSet().where((v) => v > 0 && v < goalCount).toList();
  values.sort();

  return values;
}

int _getStepSize(int goalCount) {
  if (goalCount <= 10) return 1;
  if (goalCount <= 50) return 5;
  if (goalCount <= 100) return 10;
  if (goalCount <= 200) return 20;
  if (goalCount <= 500) return 50;
  if (goalCount <= 1000) return 100;
  if (goalCount <= 2000) return 200;
  if (goalCount <= 5000) return 500;
  if (goalCount <= 10000) return 1000;
  return 2000;
}
