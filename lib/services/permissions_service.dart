import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionsServiceProvider = Provider((ref) => PermissionsService());

class PermissionsService {
  static const _channel = MethodChannel('com.jeda.app/permissions');

  Future<bool> isAccessibilityEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isUsageStatsEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isUsageStatsEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isNotificationGranted() async {
    try {
      return await _channel.invokeMethod<bool>('isNotificationPermissionGranted') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print('openAccessibilitySettings error: $e');
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      await _channel.invokeMethod('openUsageStatsSettings');
    } on PlatformException catch (e) {
      print('openUsageStatsSettings error: $e');
    }
  }
}
