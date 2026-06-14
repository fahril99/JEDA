class MotivationMessage {
  final String id;
  final String text;
  final String category;
  final String tone;
  final bool isEnabled;
  final int weight;
  final String? targetPackageName;
  final int? lastShownAt;
  final int? helpfulRating;
  final bool isDefault;
  final int createdAt;

  const MotivationMessage({
    required this.id,
    required this.text,
    required this.category,
    this.tone = 'gentle',
    this.isEnabled = true,
    this.weight = 5,
    this.targetPackageName,
    this.lastShownAt,
    this.helpfulRating,
    this.isDefault = false,
    required this.createdAt,
  });

  MotivationMessage copyWith({
    String? id,
    String? text,
    String? category,
    String? tone,
    bool? isEnabled,
    int? weight,
    String? targetPackageName,
    int? lastShownAt,
    int? helpfulRating,
    bool? isDefault,
    int? createdAt,
  }) {
    return MotivationMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      tone: tone ?? this.tone,
      isEnabled: isEnabled ?? this.isEnabled,
      weight: weight ?? this.weight,
      targetPackageName: targetPackageName ?? this.targetPackageName,
      lastShownAt: lastShownAt ?? this.lastShownAt,
      helpfulRating: helpfulRating ?? this.helpfulRating,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'category': category,
    'tone': tone,
    'is_enabled': isEnabled ? 1 : 0,
    'weight': weight,
    'target_package_name': targetPackageName,
    'last_shown_at': lastShownAt,
    'helpful_rating': helpfulRating,
    'is_default': isDefault ? 1 : 0,
    'created_at': createdAt,
  };

  factory MotivationMessage.fromMap(Map<String, dynamic> map) => MotivationMessage(
    id: map['id'] as String,
    text: map['text'] as String,
    category: map['category'] as String,
    tone: map['tone'] as String? ?? 'gentle',
    isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
    weight: map['weight'] as int? ?? 5,
    targetPackageName: map['target_package_name'] as String?,
    lastShownAt: map['last_shown_at'] as int?,
    helpfulRating: map['helpful_rating'] as int?,
    isDefault: (map['is_default'] as int? ?? 0) == 1,
    createdAt: map['created_at'] as int,
  );
}
