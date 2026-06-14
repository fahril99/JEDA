class TargetApp {
  final String packageName;
  final String appLabel;
  final String? iconBase64;
  final bool isEnabled;
  final int defaultCountdownSec;
  final String protectionLevel;
  final int createdAt;

  const TargetApp({
    required this.packageName,
    required this.appLabel,
    this.iconBase64,
    this.isEnabled = true,
    this.defaultCountdownSec = 5,
    this.protectionLevel = 'gentle',
    required this.createdAt,
  });

  TargetApp copyWith({
    String? packageName,
    String? appLabel,
    String? iconBase64,
    bool? isEnabled,
    int? defaultCountdownSec,
    String? protectionLevel,
    int? createdAt,
  }) {
    return TargetApp(
      packageName: packageName ?? this.packageName,
      appLabel: appLabel ?? this.appLabel,
      iconBase64: iconBase64 ?? this.iconBase64,
      isEnabled: isEnabled ?? this.isEnabled,
      defaultCountdownSec: defaultCountdownSec ?? this.defaultCountdownSec,
      protectionLevel: protectionLevel ?? this.protectionLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'package_name': packageName,
    'app_label': appLabel,
    'icon_base64': iconBase64,
    'is_enabled': isEnabled ? 1 : 0,
    'default_countdown_sec': defaultCountdownSec,
    'protection_level': protectionLevel,
    'created_at': createdAt,
  };

  factory TargetApp.fromMap(Map<String, dynamic> map) => TargetApp(
    packageName: map['package_name'] as String,
    appLabel: map['app_label'] as String,
    iconBase64: map['icon_base64'] as String?,
    isEnabled: (map['is_enabled'] as int) == 1,
    defaultCountdownSec: map['default_countdown_sec'] as int? ?? 5,
    protectionLevel: map['protection_level'] as String? ?? 'gentle',
    createdAt: map['created_at'] as int,
  );
}
