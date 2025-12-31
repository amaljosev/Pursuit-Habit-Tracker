import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pursuit/core/extensions/context_extensions.dart';
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

Future<void> _showIconPicker(BuildContext context, int id) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: context.screenWidth * 0.95),
    barrierColor: Colors.black54, // Adds backdrop dimming
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5, // 50%
        minChildSize: 0.25, // 25%
        maxChildSize: 0.75, // 75%
        snap: true,
        snapSizes: const [0.25, 0.5, 0.75],
        snapAnimationDuration: const Duration(milliseconds: 200),
        builder: (context, scrollController) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with drag indicator
              Container(
                height: 40,

                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  alignment: AlignmentGeometry.centerRight,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 5,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[500],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(
                      context.screenWidth > 768 ? 30 : 16,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.screenWidth > 768 ? 8 : 6,
                      mainAxisSpacing: context.screenWidth > 768 ? 25 : 10,
                      crossAxisSpacing: context.screenWidth > 768 ? 25 : 10,
                    ),
                    itemCount: HabitIcons.emojis.length,
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        context.read<HabitBloc>().add(
                          HabitIconEvent(icon: index),
                        );
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: id == index
                            ? Colors.indigo[200]
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.transparent
                            : Colors.grey[200],
                        child: Text(
                          HabitIcons.emojis[index]['emoji'],
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontSize: context.screenWidth > 768
                                    ? context.screenWidth * 0.035
                                    : context.screenWidth * 0.05,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
