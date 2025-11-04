import 'package:flutter/material.dart';
import 'package:pursuit/app/pages/settings_page.dart';
import 'package:pursuit/features/diary/pages/diary_screen.dart';
import 'package:pursuit/features/habit/presentation/pages/goals/goals_screen.dart';
import 'package:pursuit/features/todo/pages/todo_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Navigation pages
  final List<Widget> _pages = [
    GoalsScreen(),
    TodoScreen(),
    DiaryScreen(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRSuperellipse(
      borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
      
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline_sharp),
            activeIcon: Icon(Icons.check_circle),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            activeIcon: Icon(Icons.view_list),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
