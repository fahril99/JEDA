class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int? unlockedAt;
  final int progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.progress,
    required this.target,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progressRatio => (progress / target).clamp(0.0, 1.0);

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? unlockedAt,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'unlocked_at': unlockedAt,
    'progress': progress,
    'target': target,
  };

  factory Achievement.fromMap(Map<String, dynamic> map, Map<String, dynamic> meta) =>
      Achievement(
        id: map['id'] as String,
        title: meta['title'] as String,
        description: meta['description'] as String,
        icon: meta['icon'] as String,
        unlockedAt: map['unlocked_at'] as int?,
        progress: map['progress'] as int,
        target: map['target'] as int,
      );
}

class StreakData {
  final int mainStreak;
  final int focusStreak;
  final int recoveryStreak;
  final DateTime? lastStreakDate;

  const StreakData({
    this.mainStreak = 0,
    this.focusStreak = 0,
    this.recoveryStreak = 0,
    this.lastStreakDate,
  });

  StreakData copyWith({
    int? mainStreak,
    int? focusStreak,
    int? recoveryStreak,
    DateTime? lastStreakDate,
  }) {
    return StreakData(
      mainStreak: mainStreak ?? this.mainStreak,
      focusStreak: focusStreak ?? this.focusStreak,
      recoveryStreak: recoveryStreak ?? this.recoveryStreak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
    );
  }
}
