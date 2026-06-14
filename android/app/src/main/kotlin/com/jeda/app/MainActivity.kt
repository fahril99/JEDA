package com.jeda.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var interceptionHandler: InterceptionMethodHandler
    private lateinit var appsHandler: AppsMethodHandler
    private lateinit var permissionsHandler: PermissionsMethodHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register method channel handlers
        interceptionHandler = InterceptionMethodHandler(this, flutterEngine.dartExecutor.binaryMessenger)
        appsHandler = AppsMethodHandler(this, flutterEngine.dartExecutor.binaryMessenger)
        permissionsHandler = PermissionsMethodHandler(this, flutterEngine.dartExecutor.binaryMessenger)

        // Register this engine so accessibility service can reference it
        FlutterEngineStore.mainEngine = flutterEngine
    }

    override fun onDestroy() {
        FlutterEngineStore.mainEngine = null
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        // Sync target apps on resume in case they changed while app was paused
        interceptionHandler.syncTargetAppsFromPrefs()
    }
}
