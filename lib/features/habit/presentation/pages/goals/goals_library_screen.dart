import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pursuit/app/pages/home_page.dart';
import 'package:pursuit/core/functions/helper_functions.dart';
import 'package:pursuit/features/habit/constants/habit_category.dart';
import 'package:pursuit/features/habit/constants/habit_library.dart';
import 'package:pursuit/features/habit/presentation/pages/create/add_habit_screen.dart';

class GoalsLibraryScreen extends StatelessWidget {
  const GoalsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: HabitCategory.categories.length,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) =>
            Navigator.pushAndRemoveUntil(
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
              'Goals Library',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            elevation: 0,
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
          ),
          body: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: TabBar(
                  padding: const EdgeInsets.all(10),
                  isScrollable: true,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),

                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  splashFactory: NoSplash.splashFactory,
                  tabs: HabitCategory.categories.map((category) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getCategoryColor(
                                category['id'],
                              ).withValues(alpha: 0.1),
                            ),
                            child: Text(
                              HelperFunctions.getEmojiById(category['icon']),
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: HabitCategory.categories.map((category) {
                    return _HabitListByCategory(
                      categoryId: category['id'],
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Text(
              'Custom Habit',
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: Colors.white),
            ),
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => AddHabitScreen())),
            backgroundColor: Colors.blue,
            elevation: 4,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return Colors.orange; // Health
      case 2:
        return Colors.green; // Productivity
      case 3:
        return Colors.purple; // Learning
      case 4:
        return Colors.blue; // Fitness
      case 5:
        return Colors.pink; // Mindfulness
      case 6:
        return Colors.teal; // Finance
      default:
        return Colors.blue;
    }
  }
}

class _HabitListByCategory extends StatelessWidget {
  final int categoryId;
  final bool isDark;

  const _HabitListByCategory({required this.categoryId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final filteredHabits = HabitLibrary.habitsList
        .where((h) => h['category'] == categoryId)
        .toList();

    if (filteredHabits.isEmpty) {
      return const Center(child: Text('No habits found'));
    }

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: filteredHabits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = filteredHabits[index];

          return GestureDetector(
            onTap: () {
              final customHabit = LibraryModel(
                title: habit['name'],
                icon: habit['icon'],
                cat: habit['category'],
                defaultGoal: habit['defaultGoal'],
                measure: habit['measure']
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddHabitScreen(customHabit: customHabit),
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
                children: [
                  Text(
                    HelperFunctions.getEmojiById(habit['icon']),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 12),
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
  final int measure;
  final int defaultGoal;

  LibraryModel({
    required this.title,
    required this.icon,
    required this.cat,
    this.measure = 0,
    this.defaultGoal = 1,
  });
  
}
