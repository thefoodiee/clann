import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/time_table.dart';

class TimetableDB {
  static final TimetableDB instance = TimetableDB._init();
  static Database? _database;

  TimetableDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('timetable.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE timetable (
        t_id INTEGER PRIMARY KEY,
        course_name TEXT NOT NULL,
        course_id TEXT NOT NULL,
        class_code TEXT NOT NULL,
        day TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_metadata (
        id INTEGER PRIMARY KEY,
        last_update TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop and recreate table with correct schema
      await db.execute('DROP TABLE IF EXISTS timetable');
      await db.execute('DROP TABLE IF EXISTS cache_metadata');

      await _createDB(db, newVersion);
    }
  }

  // Method to completely recreate database when schema issues occur
  Future<void> recreateDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'timetable.db');

      // Delete the existing database file
      await deleteDatabase(path);

      // Reset the database reference
      _database = null;

      // Initialize new database
      _database = await _initDB('timetable.db');

    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSlots(List<TimeTable> slots) async {
    try {
      final db = await instance.database;

      // Clear existing data
      await db.delete('timetable');
      await db.delete('cache_metadata');

      // Insert new slots
      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      for (final slot in slots) {
        batch.insert('timetable', {
          't_id': slot.tId,
          'course_name': slot.courseName,
          'course_id': slot.courseId,
          'class_code': slot.classCode,
          'day': slot.day,
          'start_time': slot.startTime.toIso8601String(),
          'end_time': slot.endTime.toIso8601String(),
          'created_at': now,
          'updated_at': now,
        });
      }

      // Insert cache metadata
      batch.insert('cache_metadata', {
        'id': 1,
        'last_update': now,
      });

      await batch.commit();

    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimeTable>> getSlots() async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'timetable',
        orderBy: 'start_time ASC',
      );


      return maps.map((map) => TimeTable(
        tId: map['t_id'] as int,
        courseName: map['course_name'] as String,
        courseId: map['course_id'] as String,
        classCode: map['class_code'] as String,
        day: map['day'] as String,
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: DateTime.parse(map['end_time'] as String),
        programID: (map['program_id'] ?? '').toString(),
      )).toList();

    } catch (e) {
      rethrow;
    }
  }

  Future<List<TimeTable>> getSlotsByDay(String day) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'timetable',
        where: 'LOWER(day) = LOWER(?)',
        whereArgs: [day],
        orderBy: 'start_time ASC',
      );

      return maps.map((map) => TimeTable(
        tId: map['t_id'] as int,
        courseName: map['course_name'] as String,
        courseId: map['course_id'] as String,
        classCode: map['class_code'] as String,
        day: map['day'] as String,
        startTime: DateTime.parse(map['start_time'] as String),
        endTime: DateTime.parse(map['end_time'] as String),
        programID: (map['program_id'] ?? '').toString(),
      )).toList();

    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasCachedData() async {
    try {
      final db = await instance.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM timetable');
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> getLastCacheUpdate() async {
    try {
      final db = await instance.database;
      final maps = await db.query('cache_metadata', where: 'id = ?', whereArgs: [1]);

      if (maps.isNotEmpty) {
        return DateTime.parse(maps.first['last_update'] as String);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final db = await instance.database;
      await db.delete('timetable');
      await db.delete('cache_metadata');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}