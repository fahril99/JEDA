import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/achievement_dao.dart';
import '../local/database/dao/interception_event_dao.dart';
import '../local/database/dao/relapse_journal_dao.dart';
import '../local/database/dao/focus_session_dao.dart';
import '../local/database/dao/daily_commitment_dao.dart';
import '../../core/constants/achievement_keys.dart';
import '../../domain/models/achievement.dart';

final achievementRepositoryProvider = Provider((ref) => AchievementRepository(
  AchievementDao(AppDatabase()),
  InterceptionEventDao(AppDatabase()),
  RelapseJournalDao(AppDatabase()),
  FocusSessionDao(AppDatabase()),
  DailyCommitmentDao(AppDatabase()),
));

class AchievementRepository {
  final AchievementDao _dao;
  final InterceptionEventDao _eventDao;
  final RelapseJournalDao _journalDao;
  final FocusSessionDao _focusDao;
  final DailyCommitmentDao _commitmentDao;

  AchievementRepository(
    this._dao,
    this._eventDao,
    this._journalDao,
    this._focusDao,
    this._commitmentDao,
  );

  Future<List<Achievement>> getAll() => _dao.getAll();

  /// Called after every interception event to check and award achievements
  Future<List<Achievement>> checkAndAward({
    required String userAction,
    required int currentStreak,
  }) async {
    final newlyUnlocked = <Achievement>[];

    // First Pause
    final events = await _eventDao.getRecent(3650);
    if (events.length == 1) {
      final unlocked = await _dao.unlock(AchievementKeys.firstPause);
      if (unlocked) newlyUnlocked.add((await _dao.getById(AchievementKeys.firstPause))!);
    }

    // First Better Choice
    if (userAction == 'cancelled') {
      final cancelled = events.where((e) => e.wasCancelled).length;
      if (cancelled == 1) {
        final unlocked = await _dao.unlock(AchievementKeys.firstBetterChoice);
        if (unlocked) newlyUnlocked.add((await _dao.getById(AchievementKeys.firstBetterChoice))!);
      }
    }

    // Streak achievements
    for (final milestone in [3, 7, 14, 30, 60, 90]) {
      if (currentStreak >= milestone) {
        final key = _streakKey(milestone);
        if (key != null) {
          final unlocked = await _dao.unlock(key);
          if (unlocked) newlyUnlocked.add((await _dao.getById(key))!);
        }
      }
    }

    // Night Shield — cancelled during 22:00–02:00
    if (userAction == 'cancelled') {
      final hour = DateTime.now().hour;
      if (hour >= 22 || hour < 2) {
        await _dao.incrementProgress(AchievementKeys.nightShield);
        final a = await _dao.getById(AchievementKeys.nightShield);
        if (a != null && a.isUnlocked) newlyUnlocked.add(a);
      }
    }

    // Pattern Finder — journal entries
    final journalCount = await _journalDao.getCount();
    await _dao.setProgress(AchievementKeys.patternFinder, journalCount);
    final pf = await _dao.getById(AchievementKeys.patternFinder);
    if (pf != null && pf.isUnlocked && !newlyUnlocked.any((a) => a.id == AchievementKeys.patternFinder)) {
      newlyUnlocked.add(pf);
    }

    // Focus Champion
    final focusCount = await _focusDao.getCompletedCount();
    await _dao.setProgress(AchievementKeys.focusChampion, focusCount);

    // Commitment Keeper
    final commitmentCount = await _commitmentDao.getCompletedCount();
    await _dao.setProgress(AchievementKeys.commitmentKeeper, commitmentCount);

    return newlyUnlocked;
  }

  Future<void> checkHonestReflection() async {
    final unlocked = await _dao.unlock(AchievementKeys.honestReflection);
    // No need to notify for this one — it's a private award
  }

  String? _streakKey(int milestone) {
    switch (milestone) {
      case 3: return AchievementKeys.streak3;
      case 7: return AchievementKeys.streak7;
      case 14: return AchievementKeys.streak14;
      case 30: return AchievementKeys.streak30;
      case 60: return AchievementKeys.streak60;
      case 90: return AchievementKeys.streak90;
      default: return null;
    }
  }
}
