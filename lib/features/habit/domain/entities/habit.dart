import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String name;
  final int icon;
  final int color;
  final int type;
  final int goalValue;
  final int goalCount;
  final int time;
  final String? reminder;
  final DateTime startDate;
  final DateTime? endDate;
  final int goalRecordCount;
  final int streakCount;
  final int bestStreak;
  final int countThisMonth;
  final int countLastMonth;
  final int countThisWeek;
  final int countLastWeek;
  final int countThisYear;
  final int countLastYear;
  final List<Map<String, dynamic>> completedDays;
  final Map<String, bool> achievements;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.goalValue,
    required this.goalCount,
    required this.time,
    this.reminder,
    required this.startDate,
    this.endDate,
    required this.goalRecordCount,
    required this.streakCount,
    required this.bestStreak,
    required this.countThisMonth,
    required this.countLastMonth,
    required this.countThisWeek,
    required this.countLastWeek,
    required this.countThisYear,
    required this.countLastYear,
    required this.completedDays,
    required this.achievements,
  });


  Map<String, dynamic>? _recordFor(DateTime date) {
    final key = _dateKey(date);
    try {
      return completedDays.firstWhere((e) => e['date'] == key);
    } catch (_) {
      return null;
    }
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isCompletedOnDate(DateTime date) =>
      _recordFor(date)?['isCompleted'] == true;

  int getCountForDate(DateTime date) =>
      (_recordFor(date)?['count'] as int?) ?? 0;

  /// Convenience – true when TODAY is marked completed.
  bool get isCompleteToday => isCompletedOnDate(DateTime.now());

  /// The most recent date that was marked completed (null if none).
  DateTime? get lastCompleted {
    final completed = completedDays
        .where((e) => e['isCompleted'] == true)
        .map((e) => DateTime.tryParse(e['date'] as String? ?? ''))
        .whereType<DateTime>()
        .toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.compareTo(a));
    return completed.first;
  }

  /// Today's progress count (derived).
  int get goalCompletedCount => getCountForDate(DateTime.now());

  // ─── copyWith ───────────────────────────────────────────────────────────────

  Habit copyWith({
    String? id,
    String? name,
    int? icon,
    int? color,
    int? type,
    int? goalValue,
    int? goalCount,
    int? time,
    String? reminder,
    DateTime? startDate,
    DateTime? endDate,
    int? goalRecordCount,
    int? streakCount,
    int? bestStreak,
    int? countThisMonth,
    int? countLastMonth,
    int? countThisWeek,
    int? countLastWeek,
    int? countThisYear,
    int? countLastYear,
    List<Map<String, dynamic>>? completedDays,
    Map<String, bool>? achievements,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      goalValue: goalValue ?? this.goalValue,
      goalCount: goalCount ?? this.goalCount,
      time: time ?? this.time,
      reminder: reminder ?? this.reminder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goalRecordCount: goalRecordCount ?? this.goalRecordCount,
      streakCount: streakCount ?? this.streakCount,
      bestStreak: bestStreak ?? this.bestStreak,
      countThisMonth: countThisMonth ?? this.countThisMonth,
      countLastMonth: countLastMonth ?? this.countLastMonth,
      countThisWeek: countThisWeek ?? this.countThisWeek,
      countLastWeek: countLastWeek ?? this.countLastWeek,
      countThisYear: countThisYear ?? this.countThisYear,
      countLastYear: countLastYear ?? this.countLastYear,
      completedDays: completedDays ?? this.completedDays,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object?> get props => [
        id, name, icon, color, type, goalValue, goalCount, time, reminder,
        startDate, endDate, goalRecordCount, streakCount, bestStreak,
        countThisMonth, countLastMonth, countThisWeek, countLastWeek,
        countThisYear, countLastYear, completedDays, achievements,
      ];
}