import 'dart:convert';
import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pursuit/features/habit/data/models/habit_model.dart';

abstract class HabitLocalDataSource {
  Future<void> insertHabit(HabitModel habit);
  Future<List<HabitModel>> getAllHabits();
  Future<void> deleteHabit(String id);
  Future<void> updateHabit(HabitModel habit);
  Future<HabitModel?> getHabitById(String id);
  Future<void> updateHabitField({
    required String id,
    required String fieldName,
    required dynamic newValue,
  });
  Future<void> updateHabits(List<HabitModel> habits);

  Future<void> markHabitForDate({
    required String habitId,
    required DateTime date,
    required int count,
    required bool isCompleted,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  static const _tableName = 'habits';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'habits.db');

      final db = await openDatabase(
        path,
        version: 4,
        onCreate: (db, version) async {
          await _createTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 4) {
            await _migrateToV4(db);
          }
        },
      );

      return db;
    } catch (e, st) {
      log('Database initialization failed: $e\n$st');
      rethrow;
    }
  }

  // ─── Schema ────────────────────────────────────────────────────────────────

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon INTEGER,
        color INTEGER,
        type INTEGER,
        goalValue INTEGER,
        goalCount INTEGER,
        time INTEGER,
        reminder TEXT,
        startDate TEXT,
        endDate TEXT,
        goalRecordCount INTEGER,
        streakCount INTEGER,
        bestStreak INTEGER,
        countThisMonth INTEGER,
        countLastMonth INTEGER,
        countThisWeek INTEGER,
        countLastWeek INTEGER,
        countThisYear INTEGER,
        countLastYear INTEGER,
        completedDays TEXT,
        achievements TEXT
      )
    ''');
  }

  Future<void> _migrateToV4(Database db) async {
    log('🔄 Migrating habits DB v3 → v4 ...');

    await db.execute('''
      CREATE TABLE habits_v4 (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon INTEGER,
        color INTEGER,
        type INTEGER,
        goalValue INTEGER,
        goalCount INTEGER,
        time INTEGER,
        reminder TEXT,
        startDate TEXT,
        endDate TEXT,
        goalRecordCount INTEGER,
        streakCount INTEGER,
        bestStreak INTEGER,
        countThisMonth INTEGER,
        countLastMonth INTEGER,
        countThisWeek INTEGER,
        countLastWeek INTEGER,
        countThisYear INTEGER,
        countLastYear INTEGER,
        completedDays TEXT,
        achievements TEXT
      )
    ''');

    // Copy rows – SQLite will ignore missing destination columns automatically
    await db.execute('''
      INSERT INTO habits_v4 (
        id, name, icon, color, type, goalValue, goalCount, time, reminder,
        startDate, endDate, goalRecordCount, streakCount, bestStreak,
        countThisMonth, countLastMonth, countThisWeek, countLastWeek,
        countThisYear, countLastYear, completedDays, achievements
      )
      SELECT
        id, name, icon, color, type, goalValue, goalCount, time, reminder,
        startDate, endDate, goalRecordCount, streakCount, bestStreak,
        countThisMonth, countLastMonth, countThisWeek, countLastWeek,
        countThisYear, countLastYear, completedDays, achievements
      FROM $_tableName
    ''');

    await db.execute('DROP TABLE $_tableName');
    await db.execute('ALTER TABLE habits_v4 RENAME TO $_tableName');

    log('✅ Migration to v4 complete');
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toDbMap(HabitModel habit) {
    final data = habit.toJson();
    data['completedDays'] = jsonEncode(habit.completedDays);
    data['achievements'] = jsonEncode(habit.achievements);
    // Remove fields that no longer have DB columns (safety guard)
    data.remove('isCompleteToday');
    data.remove('lastCompleted');
    data.remove('goalCompletedCount');
    return data;
  }

  HabitModel _fromRow(Map<String, dynamic> row) {
    return HabitModel.fromJson({
      ...row,
      'completedDays': jsonDecode(row['completedDays'] as String? ?? '[]'),
      'achievements': jsonDecode(row['achievements'] as String? ?? '{}'),
    });
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── Interface implementation ──────────────────────────────────────────────

  @override
  Future<void> insertHabit(HabitModel habit) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        _toDbMap(habit),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log('Habit inserted: ${habit.name}');
    } catch (e, st) {
      log('Error inserting habit: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<HabitModel>> getAllHabits() async {
    try {
      final db = await database;
      final result = await db.query(_tableName);
      log('Fetched ${result.length} habits');
      return result.map(_fromRow).toList();
    } catch (e, st) {
      log('Error getting habits: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final db = await database;
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      log('Deleted habit: $id');
    } catch (e, st) {
      log('Error deleting habit: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        _toDbMap(habit),
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      log('Updated habit: ${habit.id}');
    } catch (e, st) {
      log('Error updating habit: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    try {
      final db = await database;
      final result = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return _fromRow(result.first);
    } catch (e, st) {
      log('Error fetching habit by ID: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateHabitField({
    required String id,
    required String fieldName,
    required dynamic newValue,
  }) async {
    final db = await database;
    try {
      await db.update(
        _tableName,
        {fieldName: newValue},
        where: 'id = ?',
        whereArgs: [id],
      );
      log('✅ Updated $fieldName for habit $id');
    } catch (e, st) {
      log('❌ Failed to update $fieldName: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateHabits(List<HabitModel> habits) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final habit in habits) {
        batch.update(
          _tableName,
          _toDbMap(habit),
          where: 'id = ?',
          whereArgs: [habit.id],
        );
      }
      await batch.commit(noResult: true);
      log('✅ Batch updated ${habits.length} habits');
    } catch (e, st) {
      log('❌ Error batch updating habits: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> markHabitForDate({
    required String habitId,
    required DateTime date,
    required int count,
    required bool isCompleted,
  }) async {
    final habit = await getHabitById(habitId);
    if (habit == null) {
      log('markHabitForDate: habit $habitId not found');
      return;
    }

    final key = _dateKey(date);
    final days = List<Map<String, dynamic>>.from(habit.completedDays);

    final idx = days.indexWhere((e) => e['date'] == key);
    if (idx >= 0) {
      days[idx] = {'date': key, 'count': count, 'isCompleted': isCompleted};
    } else {
      days.add({'date': key, 'count': count, 'isCompleted': isCompleted});
    }

    final updated = habit.copyWith(completedDays: days);
    await updateHabit(updated);
    log(
      '✅ markHabitForDate: $habitId on $key → count=$count completed=$isCompleted',
    );
  }
}
