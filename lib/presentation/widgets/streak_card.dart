import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int mainStreak;
  final int focusStreak;
  final int recoveryStreak;

  const StreakCard({
    super.key,
    required this.mainStreak,
    this.focusStreak = 0,
    this.recoveryStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1E35), Color(0xFF0A1828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _StreakColumn(
            value: mainStreak,
            label: 'Streak Utama',
            emoji: mainStreak >= 7 ? '🔥' : '⭐',
            color: AppColors.emerald,
          ),
          _divider(),
          _StreakColumn(
            value: focusStreak,
            label: 'Fokus',
            emoji: '🎯',
            color: AppColors.softBlue,
          ),
          _divider(),
          _StreakColumn(
            value: recoveryStreak,
            label: 'Recovery',
            emoji: '💪',
            color: AppColors.warningSoft,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.border,
      );
}

class _StreakColumn extends StatelessWidget {
  final int value;
  final String label;
  final String emoji;
  final Color color;

  const _StreakColumn({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value == 1 ? 'hari' : 'hari',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
