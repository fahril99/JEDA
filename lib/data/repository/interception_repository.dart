import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/interception_event_dao.dart';
import '../../domain/models/interception_event.dart';

final interceptionRepositoryProvider = Provider((ref) => InterceptionRepository(
  InterceptionEventDao(AppDatabase()),
));

class InterceptionRepository {
  final InterceptionEventDao _dao;
  InterceptionRepository(this._dao);

  Future<void> recordEvent({
    required String packageName,
    required int countdownSec,
    required String userAction,
    String? messageId,
    String? commitmentId,
    String? reason,
    String protectionLevel = 'gentle',
  }) async {
    final event = InterceptionEvent(
      id: const Uuid().v4(),
      packageName: packageName,
      startedAt: DateTime.now().millisecondsSinceEpoch,
      countdownSec: countdownSec,
      userAction: userAction,
      messageId: messageId,
      commitmentId: commitmentId,
      reason: reason,
      protectionLevel: protectionLevel,
    );
    await _dao.insert(event);
  }

  Future<List<InterceptionEvent>> getToday() => _dao.getToday();
  Future<List<InterceptionEvent>> getRecent(int days) => _dao.getRecent(days);
  Future<int> getTodayCount() => _dao.getTodayCount();
  Future<int> getTodayCancelledCount() => _dao.getTodayCancelledCount();
  Future<Map<String, int>> getActionCounts({int days = 30}) => _dao.getActionCounts(days: days);
  Future<Map<String, int>> getAppCounts({int days = 30}) => _dao.getAppInterceptionCounts(days: days);
  Future<Map<int, int>> getHourlyDistribution({int days = 30}) => _dao.getHourlyDistribution(days: days);
}
