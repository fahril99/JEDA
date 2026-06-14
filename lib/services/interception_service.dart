import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final interceptionServiceProvider = Provider((ref) => InterceptionService());

/// Bridge between Flutter and native Kotlin InterceptionCoordinator.
/// Sends target app list updates and service enable/disable commands.
class InterceptionService {
  static const _channel = MethodChannel('com.jeda.app/interception');

  Future<void> updateTargetApps(List<String> packages) async {
    try {
      await _channel.invokeMethod('updateTargetApps', {'packages': packages});
    } on PlatformException catch (e) {
      // Non-fatal: native side may not be running yet
      print('InterceptionService.updateTargetApps error: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setServiceEnabled', {'enabled': enabled});
    } on PlatformException catch (e) {
      print('InterceptionService.setEnabled error: $e');
    }
  }

  Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isServiceEnabled');
      return result ?? true;
    } on PlatformException {
      return true;
    }
  }

  Future<List<String>> getTargetApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getTargetApps');
      return result?.cast<String>() ?? [];
    } on PlatformException {
      return [];
    }
  }
}
