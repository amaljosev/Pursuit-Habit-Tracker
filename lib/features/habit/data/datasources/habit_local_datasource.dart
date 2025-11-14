import 'dart:convert';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit_model.dart';

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
}

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
        version: 1,
        onCreate: (db, version) async {
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
            goalCompletedCount INTEGER,
            goalRecordCount INTEGER,
            isCompleteToday INTEGER,
            lastCompleted TEXT,
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
        },
      );

      return db;
    } catch (e, st) {
      log('Database initialization failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> insertHabit(HabitModel habit) async {
    try {
      final db = await database;
      final data = habit.toJson();
      data['completedDays'] = jsonEncode(habit.completedDays);
      data['achievements'] = jsonEncode(habit.achievements);
      data['isCompleteToday'] = habit.isCompleteToday ? 1 : 0;
      await db.insert(
        _tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log('Habit inserted successfully: ${habit.name}');
    } catch (e, st) {
      log('Error inserting habit: $e\n$st');
      rethrow; // rethrow to let the bloc handle the failure
    }
  }

  @override
  Future<List<HabitModel>> getAllHabits() async {
    try {
      final db = await database;
      final result = await db.query(_tableName);
      log('Fetched ${result.length} habits from DB');

      return result.map((row) {
        return HabitModel.fromJson({
          ...row,
          'completedDays': jsonDecode(row['completedDays'] as String),
          'achievements': jsonDecode(row['achievements'] as String),
          'isCompleteToday': (row['isCompleteToday'] as int) == 1,
        });
      }).toList();
    } catch (e, st) {
      log('Error getting habits: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      log('Deleted $count habit(s) with id: $id');
    } catch (e, st) {
      log('Error deleting habit: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    try {
      final db = await database;
      final data = habit.toJson();

      data['completedDays'] = jsonEncode(habit.completedDays);
      data['achievements'] = jsonEncode(habit.achievements);
      data['isCompleteToday'] = habit.isCompleteToday ? 1 : 0;

      final count = await db.update(
        _tableName,
        data,
        where: 'id = ?',
        whereArgs: [habit.id],
      );
      log('Updated $count habit(s) with id: ${habit.id}');
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

      if (result.isEmpty) {
        log('No habit found with id: $id');
        return null;
      }

      final row = result.first;
      log('Fetched habit by id: $id');

      return HabitModel.fromJson({
        ...row,
        'completedDays': jsonDecode(row['completedDays'] as String),
        'achievements': jsonDecode(row['achievements'] as String),
        'isCompleteToday': (row['isCompleteToday'] as int) == 1,
      });
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
      log('✅ Updated $fieldName for habit $id to $newValue');
    } catch (e, st) {
      log('❌ Failed to update $fieldName for habit $id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> updateHabits(List<HabitModel> habits) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final habit in habits) {
        final data = habit.toJson();
        data['completedDays'] = jsonEncode(habit.completedDays);
        data['achievements'] = jsonEncode(habit.achievements);
        data['isCompleteToday'] = habit.isCompleteToday ? 1 : 0;

        batch.update(_tableName, data, where: 'id = ?', whereArgs: [habit.id]);
      }

      await batch.commit();
      log('✅ Updated ${habits.length} habits in batch');
    } catch (e, st) {
      log('❌ Error updating habits in batch: $e\n$st');
      rethrow;
    }
  }
}
