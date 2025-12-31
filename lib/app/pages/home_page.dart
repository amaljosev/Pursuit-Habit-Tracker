import 'package:flutter/material.dart';

import 'package:pursuit/features/habit/presentation/pages/goals/goals_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GoalsScreen());
  }
}
  
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = const [
//     GoalsScreen(),
//     TodoScreen(),
//     DiaryScreen(),
//     SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Tablet breakpoint
//         if (constraints.maxWidth >= 600) {
//           return _buildTabletLayout();
//         } else {
//           return _buildMobileLayout();
//         }
//       },
//     );
//   }

//   /// Mobile Layout (unchanged behavior)
//   Widget _buildMobileLayout() {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   /// Tablet Layout
//   Widget _buildTabletLayout() {
//     return Scaffold(
//       body: Row(
//         children: [
//           _buildNavigationRail(),
//           const VerticalDivider(width: 1),
//           Expanded(
//             child: _pages[_currentIndex],
//           ),
//         ],
//       ),
//     );
//   }
// Widget _buildBottomNavigationBar() {
//     return ClipRSuperellipse(
//       borderRadius: BorderRadiusGeometry.all(Radius.circular(20)),
      
//       child: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.check_circle_outline_sharp),
//             activeIcon: Icon(Icons.check_circle),
//             label: 'Goals',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             activeIcon: Icon(Icons.view_list),
//             label: 'Todo',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.book_outlined),
//             activeIcon: Icon(Icons.book),
//             label: 'Diary',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_outlined),
//             activeIcon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationRail() {
//     return NavigationRail(
//       selectedIndex: _currentIndex,
//       onDestinationSelected: (index) {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       labelType: NavigationRailLabelType.all,
//       destinations: const [
//         NavigationRailDestination(
//           icon: Icon(Icons.check_circle_outline_sharp),
//           selectedIcon: Icon(Icons.check_circle),
//           label: Text('Goals'),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.list),
//           selectedIcon: Icon(Icons.view_list),
//           label: Text('Todo'),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.book_outlined),
//           selectedIcon: Icon(Icons.book),
//           label: Text('Diary'),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.settings_outlined),
//           selectedIcon: Icon(Icons.settings),
//           label: Text('Settings'),
//         ),
//       ],
//     );
//   }
// }
