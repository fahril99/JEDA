import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/motivation_message.dart';

class MotivationMessageDao {
  final AppDatabase _db;
  MotivationMessageDao(this._db);

  Future<List<MotivationMessage>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('motivation_message', orderBy: 'created_at DESC');
    return maps.map(MotivationMessage.fromMap).toList();
  }

  Future<List<MotivationMessage>> getEnabled({String? packageName}) async {
    final db = await _db.database;
    final maps = await db.query(
      'motivation_message',
      where: 'is_enabled = 1 AND (target_package_name IS NULL OR target_package_name = ?)',
      whereArgs: [packageName ?? ''],
    );
    return maps.map(MotivationMessage.fromMap).toList();
  }

  Future<MotivationMessage?> getById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      'motivation_message',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MotivationMessage.fromMap(maps.first);
  }

  Future<void> insert(MotivationMessage message) async {
    final db = await _db.database;
    await db.insert(
      'motivation_message',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(MotivationMessage message) async {
    final db = await _db.database;
    await db.update(
      'motivation_message',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      'motivation_message',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateLastShown(String id, int timestamp) async {
    final db = await _db.database;
    await db.update(
      'motivation_message',
      {'last_shown_at': timestamp},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> rateMessage(String id, int rating) async {
    final db = await _db.database;
    // Adjust weight based on rating
    final current = await getById(id);
    if (current == null) return;
    final newWeight = rating == 1
        ? (current.weight + 2).clamp(1, 20)
        : (current.weight - 1).clamp(1, 20);
    await db.update(
      'motivation_message',
      {'helpful_rating': rating, 'weight': newWeight},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUserMessageCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM motivation_message WHERE is_default = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> hasDefaultMessages() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM motivation_message WHERE is_default = 1',
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
