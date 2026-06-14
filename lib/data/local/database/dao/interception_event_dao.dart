import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/interception_event.dart';

class InterceptionEventDao {
  final AppDatabase _db;
  InterceptionEventDao(this._db);

  Future<void> insert(InterceptionEvent event) async {
    final db = await _db.database;
    await db.insert(
      'interception_event',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<InterceptionEvent>> getRecent(int days) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final maps = await db.query(
      'interception_event',
      where: 'started_at >= ?',
      whereArgs: [since],
      orderBy: 'started_at DESC',
    );
    return maps.map(InterceptionEvent.fromMap).toList();
  }

  Future<List<InterceptionEvent>> getToday() async {
    final db = await _db.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final maps = await db.query(
      'interception_event',
      where: 'started_at >= ?',
      whereArgs: [startOfDay],
      orderBy: 'started_at DESC',
    );
    return maps.map(InterceptionEvent.fromMap).toList();
  }

  Future<Map<String, int>> getActionCounts({int days = 30}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final result = await db.rawQuery('''
      SELECT user_action, COUNT(*) as count
      FROM interception_event
      WHERE started_at >= ?
      GROUP BY user_action
    ''', [since]);

    return {for (var row in result) row['user_action'] as String: row['count'] as int};
  }

  Future<Map<String, int>> getAppInterceptionCounts({int days = 30}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final result = await db.rawQuery('''
      SELECT package_name, COUNT(*) as count
      FROM interception_event
      WHERE started_at >= ?
      GROUP BY package_name
      ORDER BY count DESC
    ''', [since]);

    return {for (var row in result) row['package_name'] as String: row['count'] as int};
  }

  Future<Map<int, int>> getHourlyDistribution({int days = 30}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final events = await db.query(
      'interception_event',
      columns: ['started_at'],
      where: 'started_at >= ?',
      whereArgs: [since],
    );

    final map = <int, int>{};
    for (final event in events) {
      final hour = DateTime.fromMillisecondsSinceEpoch(event['started_at'] as int).hour;
      map[hour] = (map[hour] ?? 0) + 1;
    }
    return map;
  }

  Future<int> getTodayCount() async {
    final events = await getToday();
    return events.length;
  }

  Future<int> getTodayCancelledCount() async {
    final events = await getToday();
    return events.where((e) => e.wasCancelled).length;
  }
}
