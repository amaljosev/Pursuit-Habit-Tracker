import 'package:pursuit/features/habit/domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.goalValue,
    required super.goalCount,
    required super.time,
    super.reminder,
    required super.startDate,
    super.endDate,
    required super.goalRecordCount,
    required super.streakCount,
    required super.bestStreak,
    required super.countThisMonth,
    required super.countLastMonth,
    required super.countThisWeek,
    required super.countLastWeek,
    required super.countThisYear,
    required super.countLastYear,
    required super.completedDays,
    required super.achievements,
  });

  // ─── fromJson ───────────────────────────────────────────────────────────────

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as int,
      color: json['color'] as int,
      type: json['type'] as int,
      goalValue: json['goalValue'] as int,
      goalCount: json['goalCount'] as int,
      time: json['time'] as int,
      reminder: json['reminder'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      goalRecordCount: json['goalRecordCount'] as int,
      streakCount: json['streakCount'] as int,
      bestStreak: json['bestStreak'] as int,
      countThisMonth: json['countThisMonth'] as int,
      countLastMonth: json['countLastMonth'] as int,
      countThisWeek: json['countThisWeek'] as int,
      countLastWeek: json['countLastWeek'] as int,
      countThisYear: json['countThisYear'] as int,
      countLastYear: json['countLastYear'] as int,
      completedDays: (json['completedDays'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      achievements: Map<String, bool>.from(
        json['achievements'] as Map<String, dynamic>,
      ),
    );
  }

  // ─── toJson ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'goalValue': goalValue,
      'goalCount': goalCount,
      'time': time,
      'reminder': reminder,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'goalRecordCount': goalRecordCount,
      'streakCount': streakCount,
      'bestStreak': bestStreak,
      'countThisMonth': countThisMonth,
      'countLastMonth': countLastMonth,
      'countThisWeek': countThisWeek,
      'countLastWeek': countLastWeek,
      'countThisYear': countThisYear,
      'countLastYear': countLastYear,
      'completedDays': completedDays,
      'achievements': achievements,
    };
  }

  // ─── Entity ↔ Model ─────────────────────────────────────────────────────────

  factory HabitModel.fromEntity(Habit habit) => HabitModel(
        id: habit.id,
        name: habit.name,
        icon: habit.icon,
        color: habit.color,
        type: habit.type,
        goalValue: habit.goalValue,
        goalCount: habit.goalCount,
        time: habit.time,
        reminder: habit.reminder,
        startDate: habit.startDate,
        endDate: habit.endDate,
        goalRecordCount: habit.goalRecordCount,
        streakCount: habit.streakCount,
        bestStreak: habit.bestStreak,
        countThisMonth: habit.countThisMonth,
        countLastMonth: habit.countLastMonth,
        countThisWeek: habit.countThisWeek,
        countLastWeek: habit.countLastWeek,
        countThisYear: habit.countThisYear,
        countLastYear: habit.countLastYear,
        completedDays: habit.completedDays,
        achievements: habit.achievements,
      );

  Habit toEntity() => Habit(
        id: id,
        name: name,
        icon: icon,
        color: color,
        type: type,
        goalValue: goalValue,
        goalCount: goalCount,
        time: time,
        reminder: reminder,
        startDate: startDate,
        endDate: endDate,
        goalRecordCount: goalRecordCount,
        streakCount: streakCount,
        bestStreak: bestStreak,
        countThisMonth: countThisMonth,
        countLastMonth: countLastMonth,
        countThisWeek: countThisWeek,
        countLastWeek: countLastWeek,
        countThisYear: countThisYear,
        countLastYear: countLastYear,
        completedDays: completedDays,
        achievements: achievements,
      );

  @override
  HabitModel copyWith({
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
    return HabitModel(
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
}