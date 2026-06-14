import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider((ref) => NotificationService.instance);

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _channelCommitment = 'jeda_commitment';
  static const _channelReview = 'jeda_review';
  static const _channelStreak = 'jeda_streak';
  static const _channelFocus = 'jeda_focus';

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _createChannels();
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelCommitment, 'Komitmen Harian',
      description: 'Pengingat komitmen pagi hari',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelReview, 'Review Malam',
      description: 'Review harian sebelum tidur',
      importance: Importance.defaultImportance,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelStreak, 'Pencapaian Streak',
      description: 'Notifikasi milestone streak',
      importance: Importance.high,
    ));
    await android.createNotificationChannel(const AndroidNotificationChannel(
      _channelFocus, 'Focus Mode',
      description: 'Status sesi fokus aktif',
      importance: Importance.low,
    ));
  }

  Future<void> scheduleMorningReminder(int hour, int minute) async {
    await _plugin.zonedSchedule(
      1,
      'Apa niatmu hari ini? 🌅',
      'Buat komitmen harian dan mulai hari dengan sadar.',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelCommitment, 'Komitmen Harian',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: const BigTextStyleInformation(
            'Buat komitmen harian dan mulai hari dengan sadar.',
          ),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEveningReview(int hour, int minute) async {
    await _plugin.zonedSchedule(
      2,
      'Waktunya refleksi hari ini 🌙',
      'Bagaimana komitmenmu hari ini? Catat sebentar.',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelReview, 'Review Malam',
          importance: Importance.defaultImportance,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showStreakMilestone(int days) async {
    await _plugin.show(
      3,
      '🎉 $days Hari Konsisten!',
      'Luar biasa! Kamu sudah berkomitmen selama $days hari berturut-turut.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelStreak, 'Pencapaian Streak',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showFocusSessionStarted(int minutes) async {
    await _plugin.show(
      4,
      '🎯 Focus Mode Aktif',
      'Sesi fokus $minutes menit dimulai. Tetap semangat!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelFocus, 'Focus Mode',
          importance: Importance.low,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  Future<void> cancelFocusNotification() async {
    await _plugin.cancel(4);
  }

  Future<void> showAchievementUnlocked(String title, String icon) async {
    await _plugin.show(
      5,
      '$icon Pencapaian Baru!',
      'Kamu membuka: $title',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelStreak, 'Pencapaian Streak',
          importance: Importance.high,
        ),
      ),
    );
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
