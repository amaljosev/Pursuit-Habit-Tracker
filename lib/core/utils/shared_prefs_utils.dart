import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static const String _lastResetDateKey = 'last_reset_date';
  
  static Future<String?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastResetDateKey);
  }
  
  static Future<void> setLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetDateKey, date.toIso8601String());
  }
  
  static Future<void> clearLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastResetDateKey);
  }
}