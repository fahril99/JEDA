class InterceptionEvent {
  final String id;
  final String packageName;
  final int startedAt;
  final int countdownSec;
  final String userAction; // cancelled | continued | timeout
  final String? messageId;
  final String? commitmentId;
  final String? reason;
  final String protectionLevel;

  const InterceptionEvent({
    required this.id,
    required this.packageName,
    required this.startedAt,
    required this.countdownSec,
    required this.userAction,
    this.messageId,
    this.commitmentId,
    this.reason,
    this.protectionLevel = 'gentle',
  });

  bool get wasCancelled => userAction == 'cancelled';
  bool get wasContinued => userAction == 'continued';

  DateTime get startedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(startedAt);

  Map<String, dynamic> toMap() => {
    'id': id,
    'package_name': packageName,
    'started_at': startedAt,
    'countdown_sec': countdownSec,
    'message_id': messageId,
    'commitment_id': commitmentId,
    'user_action': userAction,
    'reason': reason,
    'protection_level': protectionLevel,
  };

  factory InterceptionEvent.fromMap(Map<String, dynamic> map) =>
      InterceptionEvent(
        id: map['id'] as String,
        packageName: map['package_name'] as String,
        startedAt: map['started_at'] as int,
        countdownSec: map['countdown_sec'] as int,
        userAction: map['user_action'] as String,
        messageId: map['message_id'] as String?,
        commitmentId: map['commitment_id'] as String?,
        reason: map['reason'] as String?,
        protectionLevel: map['protection_level'] as String? ?? 'gentle',
      );
}
