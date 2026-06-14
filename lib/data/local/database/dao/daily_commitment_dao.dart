import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/daily_commitment.dart';

class DailyCommitmentDao {
  final AppDatabase _db;
  DailyCommitmentDao(this._db);

  Future<DailyCommitment?> getByDate(String date) async {
    final db = await _db.database;
    final maps = await db.query(
      'daily_commitment',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DailyCommitment.fromMap(maps.first);
  }

  Future<DailyCommitment?> getToday() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    return getByDate(dateStr);
  }

  Future<List<DailyCommitment>> getRecent(int days) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr = '${since.year}-${since.month.toString().padLeft(2,'0')}-${since.day.toString().padLeft(2,'0')}';
    final maps = await db.query(
      'daily_commitment',
      where: 'date >= ?',
      whereArgs: [sinceStr],
      orderBy: 'date DESC',
    );
    return maps.map(DailyCommitment.fromMap).toList();
  }

  Future<void> insert(DailyCommitment commitment) async {
    final db = await _db.database;
    await db.insert(
      'daily_commitment',
      commitment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStatus(String id, String status, {int? reviewAt}) async {
    final db = await _db.database;
    final data = <String, dynamic>{'status': status};
    if (reviewAt != null) data['evening_review_at'] = reviewAt;
    await db.update(
      'daily_commitment',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCompletedCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) FROM daily_commitment WHERE status = 'success'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
