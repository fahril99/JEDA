import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/preferences/app_preferences.dart';
import '../../domain/models/achievement.dart';

final streakRepositoryProvider = Provider((ref) => StreakRepository(AppPreferences()));

class StreakRepository {
  final AppPreferences _prefs;
  StreakRepository(this._prefs);

  Future<StreakData> getStreakData() async {
    final count = await _prefs.streakCount;
    final lastDateStr = await _prefs.lastStreakDate;
    final recovery = await _prefs.recoveryStreakCount;
    final focus = await _prefs.focusStreakCount;

    DateTime? lastDate;
    if (lastDateStr != null) {
      lastDate = DateTime.tryParse(lastDateStr);
    }

    return StreakData(
      mainStreak: count,
      focusStreak: focus,
      recoveryStreak: recovery,
      lastStreakDate: lastDate,
    );
  }

  /// Call at end of each day if user was successful
  Future<int> incrementStreak() async {
    final data = await getStreakData();
    final today = DateTime.now();
    final todayStr = _dateStr(today);

    // Already counted today
    if (data.lastStreakDate != null &&
        _dateStr(data.lastStreakDate!) == todayStr) {
      return data.mainStreak;
    }

    // Check if yesterday — continue streak
    final yesterday = today.subtract(const Duration(days: 1));
    final isConsecutive = data.lastStreakDate != null &&
        _dateStr(data.lastStreakDate!) == _dateStr(yesterday);

    final newCount = isConsecutive ? data.mainStreak + 1 : 1;
    await _prefs.setStreakCount(newCount);
    await _prefs.setLastStreakDate(todayStr);
    return newCount;
  }

  /// Gentle reset — keeps recovery streak
  Future<void> resetStreak() async {
    final current = await _prefs.recoveryStreakCount;
    await _prefs.setStreakCount(0);
    await _prefs.setRecoveryStreakCount(current + 1);
  }

  Future<void> incrementFocusStreak() async {
    final current = await _prefs.focusStreakCount;
    await _prefs.setFocusStreakCount(current + 1);
  }

  String _dateStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
