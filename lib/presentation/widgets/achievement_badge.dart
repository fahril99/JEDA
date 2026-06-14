import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool compact;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _CompactBadge(achievement: achievement);
    return _FullBadge(achievement: achievement);
  }
}

class _FullBadge extends StatelessWidget {
  final Achievement achievement;
  const _FullBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? AppColors.emerald.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: unlocked
                    ? AppColors.emerald.withOpacity(0.12)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(achievement.icon,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (!unlocked && achievement.target > 1) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progressRatio,
                        backgroundColor: AppColors.surfaceElevated,
                        color: AppColors.softBlue,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.progress}/${achievement.target}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.emerald, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final Achievement achievement;
  const _CompactBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.35,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.emerald.withOpacity(0.12)
                  : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked
                    ? AppColors.emerald.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(achievement.icon,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
