class HabitLibrary {
  static List<Map<String, dynamic>> habitsList = [

    // ─── POPULAR (category: 0) ─── Real, high-engagement habits
    {'id': 0,  'name': 'Drink Water',       'icon': 11,  'category': 0, 'measure': 7,  'defaultGoal': 2},    // 2L
    {'id': 1,  'name': 'Morning Walk',      'icon': 394, 'category': 0, 'measure': 4,  'defaultGoal': 30},   // 30 min
    {'id': 2,  'name': 'Exercise',          'icon': 0,   'category': 0, 'measure': 4,  'defaultGoal': 30},
    {'id': 3,  'name': 'Read',              'icon': 21,  'category': 0, 'measure': 10, 'defaultGoal': 20},   // 20 pages
    {'id': 4,  'name': 'Sleep on Time',     'icon': 5,   'category': 0, 'measure': 0,  'defaultGoal': 1},
    {'id': 5,  'name': 'No Phone in Bed',   'icon': 1287,'category': 0, 'measure': 0,  'defaultGoal': 1},
    {'id': 6,  'name': 'Walk 10K Steps',    'icon': 2,   'category': 0, 'measure': 2,  'defaultGoal': 10000},
    {'id': 7,  'name': 'Meditate',          'icon': 39,  'category': 0, 'measure': 4,  'defaultGoal': 10},
    {'id': 8,  'name': 'Journal',           'icon': 29,  'category': 0, 'measure': 4,  'defaultGoal': 10},
    {'id': 9,  'name': 'Take Vitamins',     'icon': 100, 'category': 0, 'measure': 0,  'defaultGoal': 1},

    // ─── HEALTH (category: 1) ─── Practical, specific health habits
    {'id': 10, 'name': 'Drink 2L Water',    'icon': 11,  'category': 1, 'measure': 7,  'defaultGoal': 2},
    {'id': 11, 'name': 'Sleep 8 Hours',     'icon': 5,   'category': 1, 'measure': 5,  'defaultGoal': 8},
    {'id': 12, 'name': 'Eat Vegetables',    'icon': 13,  'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 13, 'name': 'No Junk Food',      'icon': 15,  'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 14, 'name': 'Take Medication',   'icon': 100, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 15, 'name': 'Brush Teeth',       'icon': 101, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 16, 'name': 'Floss',             'icon': 101, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 17, 'name': 'Skincare',          'icon': 104, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 18, 'name': 'Cold Shower',       'icon': 1214,'category': 1, 'measure': 4,  'defaultGoal': 2},    // 2 min cold
    {'id': 19, 'name': 'Eat Breakfast',     'icon': 14,  'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 20, 'name': 'No Sugar',          'icon': 19,  'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 21, 'name': 'Eat Fruits',        'icon': 10,  'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 22, 'name': 'Sleep Before 11pm', 'icon': 617, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 23, 'name': 'No Late Night Eating','icon': 19,'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 24, 'name': 'Sunlight',          'icon': 621, 'category': 1, 'measure': 4,  'defaultGoal': 15},   // 15 min
    {'id': 25, 'name': 'Green Tea',         'icon': 764, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 26, 'name': 'Posture Check',     'icon': 310, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 27, 'name': 'Wash Hands',        'icon': 102, 'category': 1, 'measure': 0,  'defaultGoal': 1},
    {'id': 28, 'name': 'Weigh Myself',      'icon': 9,   'category': 1, 'measure': 9,  'defaultGoal': 1},    // kg
    {'id': 29, 'name': 'Track Calories',    'icon': 8,   'category': 1, 'measure': 8,  'defaultGoal': 2000},

    // ─── FITNESS (category: 2) ─── Clear, actionable exercise habits
    {'id': 30, 'name': 'Morning Run',       'icon': 394, 'category': 2, 'measure': 3,  'defaultGoal': 3},    // 3km
    {'id': 31, 'name': 'Gym Workout',       'icon': 3,   'category': 2, 'measure': 4,  'defaultGoal': 60},
    {'id': 32, 'name': 'Push-ups',          'icon': 0,   'category': 2, 'measure': 12, 'defaultGoal': 30},   // reps
    {'id': 33, 'name': 'Pull-ups',          'icon': 0,   'category': 2, 'measure': 12, 'defaultGoal': 10},
    {'id': 34, 'name': 'Squats',            'icon': 0,   'category': 2, 'measure': 12, 'defaultGoal': 50},
    {'id': 35, 'name': 'Plank',             'icon': 8,   'category': 2, 'measure': 4,  'defaultGoal': 2},    // 2 min
    {'id': 36, 'name': 'Yoga',              'icon': 4,   'category': 2, 'measure': 4,  'defaultGoal': 20},
    {'id': 37, 'name': 'Stretching',        'icon': 8,   'category': 2, 'measure': 4,  'defaultGoal': 10},
    {'id': 38, 'name': 'Swimming',          'icon': 7,   'category': 2, 'measure': 4,  'defaultGoal': 30},
    {'id': 39, 'name': 'Cycling',           'icon': 6,   'category': 2, 'measure': 3,  'defaultGoal': 10},
    {'id': 40, 'name': 'Evening Walk',      'icon': 2,   'category': 2, 'measure': 4,  'defaultGoal': 30},
    {'id': 41, 'name': 'HIIT',              'icon': 409, 'category': 2, 'measure': 4,  'defaultGoal': 20},
    {'id': 42, 'name': 'Jump Rope',         'icon': 8,   'category': 2, 'measure': 4,  'defaultGoal': 10},
    {'id': 43, 'name': 'Steps Goal',        'icon': 314, 'category': 2, 'measure': 2,  'defaultGoal': 8000},
    {'id': 44, 'name': 'Home Workout',      'icon': 0,   'category': 2, 'measure': 4,  'defaultGoal': 30},
    {'id': 45, 'name': 'Badminton',         'icon': 960, 'category': 2, 'measure': 4,  'defaultGoal': 60},
    {'id': 46, 'name': 'Cricket Practice',  'icon': 955, 'category': 2, 'measure': 4,  'defaultGoal': 60},
    {'id': 47, 'name': 'Football',          'icon': 946, 'category': 2, 'measure': 4,  'defaultGoal': 60},
    {'id': 48, 'name': 'Strength Training', 'icon': 409, 'category': 2, 'measure': 11, 'defaultGoal': 4},   // sets

    // ─── GROWTH (category: 3) ─── Real self-improvement, not fluffy
    {'id': 49, 'name': 'Read Book',         'icon': 20,  'category': 3, 'measure': 10, 'defaultGoal': 20},   // pages
    {'id': 50, 'name': 'Write in Journal',  'icon': 29,  'category': 3, 'measure': 4,  'defaultGoal': 10},
    {'id': 51, 'name': 'Learn a Language',  'icon': 21,  'category': 3, 'measure': 4,  'defaultGoal': 15},
    {'id': 52, 'name': 'Coding Practice',   'icon': 23,  'category': 3, 'measure': 4,  'defaultGoal': 30},
    {'id': 53, 'name': 'Online Course',     'icon': 58,  'category': 3, 'measure': 4,  'defaultGoal': 30},
    {'id': 54, 'name': 'Listen Podcast',    'icon': 36,  'category': 3, 'measure': 4,  'defaultGoal': 20},
    {'id': 55, 'name': 'Practice Guitar',   'icon': 1011,'category': 3, 'measure': 4,  'defaultGoal': 20},
    {'id': 56, 'name': 'Drawing',           'icon': 998, 'category': 3, 'measure': 4,  'defaultGoal': 20},
    {'id': 57, 'name': 'Study',             'icon': 23,  'category': 3, 'measure': 4,  'defaultGoal': 60},
    {'id': 58, 'name': 'Call a Friend',     'icon': 41,  'category': 3, 'measure': 0,  'defaultGoal': 1},
    {'id': 59, 'name': 'Spend Time Outside','icon': 37,  'category': 3, 'measure': 4,  'defaultGoal': 30},
    {'id': 60, 'name': 'No Screen Morning', 'icon': 1287,'category': 3, 'measure': 4,  'defaultGoal': 30},   // 30 min no screen after waking
    {'id': 61, 'name': 'English practice',          'icon': 52,  'category': 3, 'measure': 4,  'defaultGoal': 10},
    {'id': 62, 'name': 'Sketch / Doodle',   'icon': 35,  'category': 3, 'measure': 4,  'defaultGoal': 15},
    {'id': 63, 'name': 'Watch Documentary', 'icon': 1082,'category': 3, 'measure': 0,  'defaultGoal': 1},

    // ─── PRODUCTIVITY (category: 4) ─── Practical planning habits
    {'id': 64, 'name': 'Wake Up Early',     'icon': 140, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 65, 'name': 'Plan My Day',       'icon': 110, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 66, 'name': 'Deep Work',         'icon': 23,  'category': 4, 'measure': 4,  'defaultGoal': 90},   // 90 min
    {'id': 67, 'name': 'Inbox Zero',        'icon': 122, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 68, 'name': 'No Social Media',   'icon': 63,  'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 69, 'name': 'Limit Screen Time', 'icon': 38,  'category': 4, 'measure': 5,  'defaultGoal': 2},    // 2 hrs max
    {'id': 70, 'name': 'Weekly Review',     'icon': 111, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 71, 'name': 'Complete 3 Tasks',  'icon': 25,  'category': 4, 'measure': 13, 'defaultGoal': 3},
    {'id': 72, 'name': 'Pomodoro Sessions', 'icon': 26,  'category': 4, 'measure': 14, 'defaultGoal': 4},
    {'id': 73, 'name': 'Make Bed',          'icon': 118, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 74, 'name': 'No Procrastinating','icon': 200, 'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 75, 'name': 'Track Expenses',    'icon': 28,  'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 76, 'name': 'Save Money',        'icon': 112, 'category': 4, 'measure': 16, 'defaultGoal': 100},  // ₹100/day
    {'id': 77, 'name': 'Clean Room',        'icon': 27,  'category': 4, 'measure': 0,  'defaultGoal': 1},
    {'id': 78, 'name': 'Check Goals',       'icon': 24,  'category': 4, 'measure': 0,  'defaultGoal': 1},

    // ─── QUIT (category: 5) ─── Honest, real bad habits people track
    {'id': 79, 'name': 'No Smoking',        'icon': 1283,'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 80, 'name': 'No Alcohol',        'icon': 61,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 81, 'name': 'No Vaping',         'icon': 1224,'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 82, 'name': 'No Junk Food',      'icon': 62,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 83, 'name': 'No Sugar',          'icon': 19,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 84, 'name': 'Limit Coffee',      'icon': 18,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 85, 'name': 'No Doom Scrolling', 'icon': 38,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 86, 'name': 'No Social Media',   'icon': 106, 'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 87, 'name': 'No Late Night Snack','icon': 19, 'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 88, 'name': 'Stop Nail Biting',  'icon': 308, 'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 89, 'name': 'No Impulse Buying', 'icon': 64,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 90, 'name': 'No Overthinking',   'icon': 183, 'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 91, 'name': 'Stop Procrastinating','icon':200,'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 92, 'name': 'No Skipping Meals', 'icon': 14,  'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 93, 'name': 'Less Screen Time',  'icon': 66,  'category': 5, 'measure': 5,  'defaultGoal': 3},    // max 3h
    {'id': 94, 'name': 'No Negative Talk',  'icon': 221, 'category': 5, 'measure': 0,  'defaultGoal': 1},
    {'id': 95, 'name': 'No Caffeine After 3pm','icon':762,'category': 5,'measure': 0,  'defaultGoal': 1},
    {'id': 96, 'name': 'Reduce Spending',   'icon': 64,  'category': 5, 'measure': 16, 'defaultGoal': 500},  // ₹ limit/day
    {'id': 97, 'name': 'No Sitting 1hr+',   'icon': 244, 'category': 5, 'measure': 0,  'defaultGoal': 1},
  ];
}