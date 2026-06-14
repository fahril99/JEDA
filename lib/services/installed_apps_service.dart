import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final installedAppsServiceProvider = Provider((ref) => InstalledAppsService());

class InstalledApp {
  final String packageName;
  final String appName;
  final String? iconBase64;
  Uint8List? _iconBytes;

  InstalledApp({
    required this.packageName,
    required this.appName,
    this.iconBase64,
  });

  Uint8List? get iconBytes {
    if (_iconBytes != null) return _iconBytes;
    if (iconBase64 != null && iconBase64!.isNotEmpty) {
      _iconBytes = base64Decode(iconBase64!);
    }
    return _iconBytes;
  }

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) => InstalledApp(
    packageName: map['packageName'] as String,
    appName: map['appName'] as String,
    iconBase64: map['icon'] as String?,
  );
}

class InstalledAppsService {
  static const _channel = MethodChannel('com.jeda.app/apps');

  List<InstalledApp>? _cache;

  Future<List<InstalledApp>> getInstalledApps({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps');
      _cache = result?.map((e) => InstalledApp.fromMap(e as Map)).toList() ?? [];
      return _cache!;
    } on PlatformException catch (e) {
      print('getInstalledApps error: $e');
      return [];
    }
  }

  Future<InstalledApp?> getAppInfo(String packageName) async {
    try {
      final result = await _channel.invokeMethod<Map>(
        'getAppInfo',
        {'packageName': packageName},
      );
      if (result == null) return null;
      return InstalledApp.fromMap(result);
    } on PlatformException {
      return null;
    }
  }

  void clearCache() => _cache = null;
}
