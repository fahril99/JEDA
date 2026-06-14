import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/focus_session_dao.dart';
import '../../domain/models/focus_session.dart';

final focusSessionRepositoryProvider = Provider((ref) => FocusSessionRepository(
  FocusSessionDao(AppDatabase()),
));

class FocusSessionRepository {
  final FocusSessionDao _dao;
  FocusSessionRepository(this._dao);

  Future<FocusSession?> getActiveSession() => _dao.getActiveSession();

  Future<FocusSession> startSession({
    required int durationMinutes,
    required List<String> targetPackages,
    String protectionLevel = 'gentle',
  }) async {
    // Cancel any existing active session first
    final existing = await _dao.getActiveSession();
    if (existing != null) {
      await _dao.updateStatus(
        existing.id,
        'cancelled',
        endedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    final session = FocusSession(
      id: const Uuid().v4(),
      startedAt: DateTime.now().millisecondsSinceEpoch,
      durationMinutes: durationMinutes,
      protectionLevel: protectionLevel,
      targetPackages: targetPackages,
      status: 'active',
    );
    await _dao.insert(session);
    return session;
  }

  Future<void> endSession(String id, {bool completed = true}) async {
    await _dao.updateStatus(
      id,
      completed ? 'completed' : 'cancelled',
      endedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<FocusSession>> getAll() => _dao.getAll();
  Future<int> getCompletedCount() => _dao.getCompletedCount();
}
