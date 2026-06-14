import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/relapse_journal.dart';

class RelapseJournalDao {
  final AppDatabase _db;
  RelapseJournalDao(this._db);

  Future<List<RelapseJournal>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('relapse_journal', orderBy: 'occurred_at DESC');
    return maps.map(RelapseJournal.fromMap).toList();
  }

  Future<List<RelapseJournal>> getRecent(int days) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final maps = await db.query(
      'relapse_journal',
      where: 'occurred_at >= ?',
      whereArgs: [since],
      orderBy: 'occurred_at DESC',
    );
    return maps.map(RelapseJournal.fromMap).toList();
  }

  Future<void> insert(RelapseJournal journal) async {
    final db = await _db.database;
    await db.insert(
      'relapse_journal',
      journal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('relapse_journal', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getTriggerFrequency({int days = 30}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final result = await db.rawQuery('''
      SELECT trigger, COUNT(*) as count
      FROM relapse_journal
      WHERE occurred_at >= ?
      GROUP BY trigger
      ORDER BY count DESC
    ''', [since]);
    return {for (var r in result) r['trigger'] as String: r['count'] as int};
  }

  Future<Map<String, int>> getEmotionFrequency({int days = 30}) async {
    final db = await _db.database;
    final since = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final result = await db.rawQuery('''
      SELECT emotion, COUNT(*) as count
      FROM relapse_journal
      WHERE occurred_at >= ?
      GROUP BY emotion
      ORDER BY count DESC
    ''', [since]);
    return {for (var r in result) r['emotion'] as String: r['count'] as int};
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM relapse_journal');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
