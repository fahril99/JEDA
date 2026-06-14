class RelapseJournal {
  final String id;
  final int occurredAt;
  final String? packageName;
  final String trigger;
  final String emotion;
  final int intensity; // 1–5
  final String? note;
  final String? nextAction;
  final int createdAt;

  const RelapseJournal({
    required this.id,
    required this.occurredAt,
    this.packageName,
    required this.trigger,
    required this.emotion,
    required this.intensity,
    this.note,
    this.nextAction,
    required this.createdAt,
  });

  DateTime get occurredAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(occurredAt);

  RelapseJournal copyWith({
    String? id,
    int? occurredAt,
    String? packageName,
    String? trigger,
    String? emotion,
    int? intensity,
    String? note,
    String? nextAction,
    int? createdAt,
  }) {
    return RelapseJournal(
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      packageName: packageName ?? this.packageName,
      trigger: trigger ?? this.trigger,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      nextAction: nextAction ?? this.nextAction,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'occurred_at': occurredAt,
    'package_name': packageName,
    'trigger': trigger,
    'emotion': emotion,
    'intensity': intensity,
    'note': note,
    'next_action': nextAction,
    'created_at': createdAt,
  };

  factory RelapseJournal.fromMap(Map<String, dynamic> map) => RelapseJournal(
    id: map['id'] as String,
    occurredAt: map['occurred_at'] as int,
    packageName: map['package_name'] as String?,
    trigger: map['trigger'] as String,
    emotion: map['emotion'] as String,
    intensity: map['intensity'] as int,
    note: map['note'] as String?,
    nextAction: map['next_action'] as String?,
    createdAt: map['created_at'] as int,
  );
}
