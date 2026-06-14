class FocusSession {
  final String id;
  final int startedAt;
  final int? endedAt;
  final int durationMinutes;
  final String protectionLevel; // gentle | strong
  final List<String> targetPackages;
  final String status; // active | completed | cancelled

  const FocusSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.durationMinutes,
    this.protectionLevel = 'gentle',
    required this.targetPackages,
    this.status = 'active',
  });

  FocusSession copyWith({
    String? id,
    int? startedAt,
    int? endedAt,
    int? durationMinutes,
    String? protectionLevel,
    List<String>? targetPackages,
    String? status,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      protectionLevel: protectionLevel ?? this.protectionLevel,
      targetPackages: targetPackages ?? this.targetPackages,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'started_at': startedAt,
    'ended_at': endedAt,
    'duration_minutes': durationMinutes,
    'protection_level': protectionLevel,
    'target_packages_json': targetPackages.join(','),
    'status': status,
  };

  factory FocusSession.fromMap(Map<String, dynamic> map) => FocusSession(
    id: map['id'] as String,
    startedAt: map['started_at'] as int,
    endedAt: map['ended_at'] as int?,
    durationMinutes: map['duration_minutes'] as int,
    protectionLevel: map['protection_level'] as String,
    targetPackages: (map['target_packages_json'] as String).split(',').where((s) => s.isNotEmpty).toList(),
    status: map['status'] as String,
  );

  bool get isActive => status == 'active';
  DateTime get startedAtDateTime => DateTime.fromMillisecondsSinceEpoch(startedAt);

  DateTime get endsAt =>
      startedAtDateTime.add(Duration(minutes: durationMinutes));

  Duration get remaining {
    final now = DateTime.now();
    final end = endsAt;
    if (now.isAfter(end)) return Duration.zero;
    return end.difference(now);
  }
}
