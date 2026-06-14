import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../../core/constants/achievement_keys.dart';
import '../../../domain/models/achievement.dart';

class AchievementDao {
  final AppDatabase _db;
  AchievementDao(this._db);

  Future<void> ensureInitialized() async {
    final db = await _db.database;
    for (final meta in AchievementKeys.allAchievements) {
      final existing = await db.query(
        'achievement',
        where: 'id = ?',
        whereArgs: [meta['id']],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('achievement', {
          'id': meta['id'],
          'unlocked_at': null,
          'progress': 0,
          'target': meta['target'],
        });
      }
    }
  }

  Future<List<Achievement>> getAll() async {
    await ensureInitialized();
    final db = await _db.database;
    final rows = await db.query('achievement', orderBy: 'unlocked_at DESC');
    return rows.map((row) {
      final meta = AchievementKeys.allAchievements
          .firstWhere((m) => m['id'] == row['id'],
              orElse: () => {'title': '', 'description': '', 'icon': '⭐', 'target': 1});
      return Achievement.fromMap(row, meta);
    }).toList();
  }

  Future<Achievement?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query('achievement', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final meta = AchievementKeys.allAchievements.firstWhere((m) => m['id'] == id, orElse: () => {'title': '', 'description': '', 'icon': '⭐', 'target': 1});
    return Achievement.fromMap(rows.first, meta);
  }

  Future<bool> unlock(String id) async {
    final db = await _db.database;
    final existing = await getById(id);
    if (existing == null || existing.isUnlocked) return false;
    await db.update(
      'achievement',
      {'unlocked_at': DateTime.now().millisecondsSinceEpoch, 'progress': existing.target},
      where: 'id = ?',
      whereArgs: [id],
    );
    return true;
  }

  Future<void> setProgress(String id, int progress) async {
    final db = await _db.database;
    final existing = await getById(id);
    if (existing == null || existing.isUnlocked) return;
    final newProgress = progress.clamp(0, existing.target);
    final Map<String, dynamic> data = {'progress': newProgress};
    if (newProgress >= existing.target) {
      data['unlocked_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    await db.update('achievement', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementProgress(String id, {int by = 1}) async {
    final existing = await getById(id);
    if (existing == null || existing.isUnlocked) return;
    await setProgress(id, existing.progress + by);
  }
}
