import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'data/repository/message_repository.dart';
import 'data/repository/achievement_repository.dart';
import 'presentation/interstitial/interstitial_screen.dart';

/// Main entry point for the full JEDA app
@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF050B14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Timezone
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Notifications
  await NotificationService.instance.initialize();

  // Seed default messages once
  final container = ProviderContainer();
  await container.read(messageRepositoryProvider).seedDefaultMessages();
  // Ensure achievements initialized
  await container.read(achievementRepositoryProvider).getAll();

  runApp(UncontrolledProviderScope(container: container, child: const JedaApp()));
}

/// Second entry point — used by InterstitialActivity (second Flutter engine)
@pragma('vm:entry-point')
void interstitialMain() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InterstitialScreen(),
  ));
}

class JedaApp extends ConsumerWidget {
  const JedaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'JEDA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
