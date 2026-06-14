import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/relapse_journal_dao.dart';
import '../../domain/models/relapse_journal.dart';

final journalRepositoryProvider = Provider((ref) => JournalRepository(
  RelapseJournalDao(AppDatabase()),
));

class JournalRepository {
  final RelapseJournalDao _dao;
  JournalRepository(this._dao);

  Future<List<RelapseJournal>> getAll() => _dao.getAll();
  Future<List<RelapseJournal>> getRecent(int days) => _dao.getRecent(days);

  Future<RelapseJournal> create({
    required String trigger,
    required String emotion,
    required int intensity,
    String? packageName,
    String? note,
    String? nextAction,
    DateTime? occurredAt,
  }) async {
    final journal = RelapseJournal(
      id: const Uuid().v4(),
      occurredAt: (occurredAt ?? DateTime.now()).millisecondsSinceEpoch,
      packageName: packageName,
      trigger: trigger,
      emotion: emotion,
      intensity: intensity,
      note: note,
      nextAction: nextAction,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.insert(journal);
    return journal;
  }

  Future<void> delete(String id) => _dao.delete(id);

  Future<Map<String, int>> getTriggerFrequency({int days = 30}) =>
      _dao.getTriggerFrequency(days: days);

  Future<Map<String, int>> getEmotionFrequency({int days = 30}) =>
      _dao.getEmotionFrequency(days: days);

  Future<int> getTotalCount() => _dao.getCount();
}
