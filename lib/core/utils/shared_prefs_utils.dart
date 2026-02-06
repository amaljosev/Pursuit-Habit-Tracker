import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _skippedRemindersKey = 'skipped_reminders';

  // ───────── DATE ─────────
  static Future<String?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastResetDateKey);
  }

  static Future<void> setLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetDateKey, date.toIso8601String());
  }

  // ───────── REMINDER LIST ─────────
  static Future<List<String>> getSkippedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_skippedRemindersKey) ?? [];
  }

  static Future<void> addSkippedReminder(String habitId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_skippedRemindersKey) ?? [];

    if (!list.contains(habitId)) {
      list.add(habitId);
      await prefs.setStringList(_skippedRemindersKey, list);
    }
  }

  static Future<void> removeSkippedReminder(String habitId) async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_skippedRemindersKey);
    if (list == null || list.isEmpty) return;

    if (!list.contains(habitId)) return;

    list.remove(habitId);

    if (list.isEmpty) {
      await prefs.remove(_skippedRemindersKey);
    } else {
      await prefs.setStringList(_skippedRemindersKey, list);
    }
  }

  static Future<void> clearSkippedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skippedRemindersKey);
  }
}
