import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../domain/models/target_app.dart';

class TargetAppDao {
  final AppDatabase _db;
  TargetAppDao(this._db);

  Future<List<TargetApp>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('target_app', orderBy: 'app_label ASC');
    return maps.map(TargetApp.fromMap).toList();
  }

  Future<List<TargetApp>> getEnabled() async {
    final db = await _db.database;
    final maps = await db.query(
      'target_app',
      where: 'is_enabled = 1',
      orderBy: 'app_label ASC',
    );
    return maps.map(TargetApp.fromMap).toList();
  }

  Future<TargetApp?> getByPackage(String packageName) async {
    final db = await _db.database;
    final maps = await db.query(
      'target_app',
      where: 'package_name = ?',
      whereArgs: [packageName],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return TargetApp.fromMap(maps.first);
  }

  Future<void> insert(TargetApp app) async {
    final db = await _db.database;
    await db.insert(
      'target_app',
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(TargetApp app) async {
    final db = await _db.database;
    await db.update(
      'target_app',
      app.toMap(),
      where: 'package_name = ?',
      whereArgs: [app.packageName],
    );
  }

  Future<void> delete(String packageName) async {
    final db = await _db.database;
    await db.delete(
      'target_app',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  Future<void> toggleEnabled(String packageName, bool enabled) async {
    final db = await _db.database;
    await db.update(
      'target_app',
      {'is_enabled': enabled ? 1 : 0},
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  Future<int> getCount() async {
    final db = await _db.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) FROM target_app WHERE is_enabled = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
