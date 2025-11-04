class AppUser {
  final String id;
  final String? name;
  final DateTime createdAt;

  // Progress
  final int totalHabitsCreated;
  final int totalTodosCreated;
  final int totalDiaryEntries;
  final int totalHabitsCompleted;
  final int streak;
  final int longestStreak;

  // Usage
  final DateTime lastLogin;
  final int dailyAppOpens;
  final int totalAppOpens;
  final int timeSpentMinutes;

  // Preferences
  final String themeMode;
  final bool notificationsEnabled;
  final String? habitReminderTime; 

  AppUser({
    required this.id,
    this.name,
    required this.createdAt,
    this.totalHabitsCreated = 0,
    this.totalTodosCreated = 0,
    this.totalDiaryEntries = 0,
    this.totalHabitsCompleted = 0,
    this.streak = 0,
    this.longestStreak = 0,
    required this.lastLogin,
    this.dailyAppOpens = 0,
    this.totalAppOpens = 0,
    this.timeSpentMinutes = 0,
    this.themeMode = "system",
    this.notificationsEnabled = true,
    this.habitReminderTime,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    int? totalHabitsCreated,
    int? totalTodosCreated,
    int? totalDiaryEntries,
    int? totalHabitsCompleted,
    int? streak,
    int? longestStreak,
    DateTime? lastLogin,
    int? dailyAppOpens,
    int? totalAppOpens,
    int? timeSpentMinutes,
    String? themeMode,
    bool? notificationsEnabled,
    String? habitReminderTime,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      totalHabitsCreated: totalHabitsCreated ?? this.totalHabitsCreated,
      totalTodosCreated: totalTodosCreated ?? this.totalTodosCreated,
      totalDiaryEntries: totalDiaryEntries ?? this.totalDiaryEntries,
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLogin: lastLogin ?? this.lastLogin,
      dailyAppOpens: dailyAppOpens ?? this.dailyAppOpens,
      totalAppOpens: totalAppOpens ?? this.totalAppOpens,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      habitReminderTime: habitReminderTime ?? this.habitReminderTime,
    );
  }
}
