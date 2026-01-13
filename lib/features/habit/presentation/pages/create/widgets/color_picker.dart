import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/theme/app_colors.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      buildWhen: (previous, current) {
        if (previous is! AddHabitInitial || current is! AddHabitInitial) {
          return false;
        }
        return previous.color != current.color;
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        if (state is! AddHabitInitial) return const SizedBox.shrink();
        final int colorIndex = state.color;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: List.generate(AppColors.lightColors.length, (index) {
            final color = isDark
                ? AppColors.darkColors[index]['color']
                : AppColors.lightColors[index]['color'];
            final int id = AppColors.lightColors[colorIndex]['id'];

            return GestureDetector(
              onTap: () {
                context.read<HabitBloc>().add(HabitColorEvent(color: index));
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: color,
                  child: Icon(
                    id == index ? Icons.check : null,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
