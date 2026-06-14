package com.jeda.app

import io.flutter.embedding.engine.FlutterEngine

/**
 * Static store for Flutter engine references.
 * Allows the AccessibilityService to communicate with the Flutter UI.
 */
object FlutterEngineStore {
    @Volatile var mainEngine: FlutterEngine? = null
    @Volatile var interstitialEngine: FlutterEngine? = null
}
