package com.jeda.app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class InterceptionMethodHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) {
    private val coordinator = InterceptionCoordinator(context)
    private val prefs = context.getSharedPreferences("jeda_prefs", Context.MODE_PRIVATE)

    init {
        MethodChannel(messenger, "com.jeda.app/interception").setMethodCallHandler { call, result ->
            when (call.method) {
                "updateTargetApps" -> {
                    val packages = call.argument<List<String>>("packages") ?: emptyList()
                    coordinator.updateTargetPackages(packages)
                    result.success(null)
                }
                "setServiceEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    coordinator.setServiceEnabled(enabled)
                    result.success(null)
                }
                "isServiceEnabled" -> result.success(coordinator.isServiceEnabled())
                "getTargetApps" -> result.success(coordinator.getTargetPackages().toList())
                else -> result.notImplemented()
            }
        }
    }

    fun syncTargetAppsFromPrefs() {
        // No-op: packages already stored in SharedPreferences by coordinator
    }
}
