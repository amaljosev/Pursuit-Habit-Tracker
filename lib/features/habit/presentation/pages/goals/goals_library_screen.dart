import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/constants/habit_category.dart';
import 'package:pursuit/features/habit/constants/habit_library.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';

class GoalsLibraryScreen extends StatefulWidget {
  const GoalsLibraryScreen({super.key});

  @override
  State<GoalsLibraryScreen> createState() => _GoalsLibraryScreenState();
}

class _GoalsLibraryScreenState extends State<GoalsLibraryScreen> {
  int selectedCategoryId = 0;

  List<Map<String, dynamic>> get filteredHabits {
    return HabitLibrary.habitsList
        .where((h) => h['category'] == selectedCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            ),
          ),
          title: Text(
            'Habit Library',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryBar(),

            Expanded(child: _buildHabitList(isDark: isDark)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text(
            'Custom Habit',
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(color: Colors.white),
          ),
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddHabitScreen())),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// 🔹 Categories
  Widget _buildCategoryBar() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        scrollDirection: Axis.horizontal,
        itemCount: HabitCategory.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = HabitCategory.categories[index];
          final isSelected = category['id'] == selectedCategoryId;

          return GestureDetector(
            onTap: () {
              setState(() => selectedCategoryId = category['id']);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    HelperFunctions.getEmojiById(category['icon']),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    category['name'],
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Habit List
  Widget _buildHabitList({required bool isDark}) {
    if (filteredHabits.isEmpty) {
      return const Center(child: Text('No habits found'));
    }

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filteredHabits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final Map<String, dynamic> habit = filteredHabits[index];

          return GestureDetector(
            onTap: () {
              final customHabit = LibraryModel(
                title: habit['name'],
                icon: habit['icon'],
                cat: habit['category'],
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AddHabitScreen(customHabit: customHabit),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                spacing: 12,
                children: [
                  Text(
                    HelperFunctions.getEmojiById(habit['icon']),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  Expanded(
                    child: Text(
                      habit['name'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const CupertinoListTileChevron(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LibraryModel {
  final String title;
  final int icon;
  final int cat;

  LibraryModel({required this.title, required this.icon, required this.cat});
}
