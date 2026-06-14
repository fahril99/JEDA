import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/focus_session.dart';

class FocusSessionDao {
  final AppDatabase _db;
  FocusSessionDao(this._db);

  Future<FocusSession?> getActiveSession() async {
    final db = await _db.database;
    final maps = await db.query(
      'focus_session',
      where: "status = 'active'",
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FocusSession.fromMap(maps.first);
  }

  Future<List<FocusSession>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('focus_session', orderBy: 'started_at DESC');
    return maps.map(FocusSession.fromMap).toList();
  }

  Future<void> insert(FocusSession session) async {
    final db = await _db.database;
    await db.insert(
      'focus_session',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStatus(String id, String status, {int? endedAt}) async {
    final db = await _db.database;
    final data = <String, dynamic>{'status': status};
    if (endedAt != null) data['ended_at'] = endedAt;
    await db.update(
      'focus_session',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCompletedCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM focus_session WHERE status = 'completed'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
