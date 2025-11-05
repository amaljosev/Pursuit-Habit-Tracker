import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/features/habit/constants/habit_icons.dart';
import 'package:pursuit/features/habit/presentation/blocs/habit/habit_bloc.dart';

class IconPickerWidget extends StatelessWidget {
  const IconPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
   
    return BlocBuilder<HabitBloc, HabitState>(
      
      buildWhen: (previous, current) {
        if (previous is AddHabitInitial && current is AddHabitInitial) {
          return previous.icon != current.icon;
        }
        return false;
      },
      builder: (context, state) {
        if (state is AddHabitInitial) {
          final selectedIcon = HabitIcons.emojis[state.icon]['emoji'];
          final selectedIconId = HabitIcons.emojis[state.icon]['id'];
          return GestureDetector(
            onTap: () => _showIconPicker(context, selectedIconId),
            child: Text(
              selectedIcon,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
// class IconPickerWidget extends StatelessWidget {
//   const IconPickerWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocSelector<HabitBloc, HabitState, int>(
//       selector: (state) => (state as AddHabitInitial).icon,
//       builder: (context, iconIndex) {
//         final selectedIcon = HabitIcons.emojis[iconIndex]['emoji'];
//         final selectedIconId = HabitIcons.emojis[iconIndex]['id'];
//         debugPrint('Rebuilding Icon Widget');
//         return GestureDetector(
//           onTap: () => _showIconPicker(context, selectedIconId),
//           child: Text(
//             selectedIcon,
//             style: Theme.of(context).textTheme.displayLarge,
//           ),
//         );
//       },
//     );
//   }
// }

Future<void> _showIconPicker(BuildContext context, int id) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: HabitIcons.emojis.length,
      itemBuilder: (_, index) => GestureDetector(
        onTap: () {
          context.read<HabitBloc>().add(HabitIconEvent(icon: index));
          Navigator.pop(context);
        },
        child: CircleAvatar(
          backgroundColor: id == index ? Colors.indigo : Colors.grey[300],
          child: Text(
            HabitIcons.emojis[index]['emoji'],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    ),
  );
}
