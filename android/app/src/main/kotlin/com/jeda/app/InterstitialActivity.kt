package com.jeda.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter interstitial overlay using a dedicated Dart entry point.
 * Uses a pre-warmed engine from FlutterEngineCache when available.
 */
class InterstitialActivity : FlutterActivity() {

    companion object {
        const val EXTRA_PACKAGE_NAME = "extra_package_name"
        const val ENGINE_ID = "jeda_interstitial_engine"
        private const val CHANNEL = "com.jeda.app/interstitial"
    }

    private var packageNameExtra: String = ""
    private var channel: MethodChannel? = null
    private val coordinator by lazy { InterceptionCoordinator(applicationContext) }

    override fun onCreate(savedInstanceState: Bundle?) {
        packageNameExtra = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: ""
        super.onCreate(savedInstanceState)
    }

    override fun getCachedEngineId(): String = ENGINE_ID

    override fun getDartEntrypointFunctionName(): String = "interstitialMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineStore.interstitialEngine = flutterEngine

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInterstitialData" -> {
                    val data = buildInterstitialData()
                    result.success(data)
                }
                "onUserAction" -> {
                    val action = call.argument<String>("action") ?: "dismissed"
                    handleUserAction(action)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun buildInterstitialData(): Map<String, Any?> {
        val prefs = getSharedPreferences("jeda_prefs", MODE_PRIVATE)
        val appLabel = getAppLabel(packageNameExtra)
        val countdownSec = coordinator.getDefaultCountdown()
        val message = prefs.getString("last_message", "") ?: ""
        val commitment = prefs.getString("today_commitment", "") ?: ""
        val lifeGoal = prefs.getString("life_goal_text", "") ?: ""
        val protectionLevel = prefs.getString("protection_level_$packageNameExtra", "gentle") ?: "gentle"

        return mapOf(
            "packageName" to packageNameExtra,
            "appLabel" to appLabel,
            "countdownSec" to countdownSec,
            "message" to message,
            "commitment" to commitment,
            "lifeGoal" to lifeGoal,
            "protectionLevel" to protectionLevel,
        )
    }

    private fun getAppLabel(packageName: String): String {
        return try {
            val pm = packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(info).toString()
        } catch (_: Exception) {
            packageName.split(".").last()
        }
    }

    private fun handleUserAction(action: String) {
        // Just close the interstitial — the user made their choice
        finish()
    }

    override fun onDestroy() {
        FlutterEngineStore.interstitialEngine = null
        channel = null
        super.onDestroy()
    }

    override fun shouldRestoreInstanceState(): Boolean = false
    override fun shouldDestroyEngineWithHost(): Boolean = false
}
