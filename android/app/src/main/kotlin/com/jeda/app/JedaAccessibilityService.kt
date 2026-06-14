package com.jeda.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

/**
 * Core monitoring service. Watches for TYPE_WINDOW_STATE_CHANGED events only.
 * Does NOT read any screen content, text, passwords, or user data.
 * Only checks the package name to decide if an interstitial should appear.
 */
class JedaAccessibilityService : AccessibilityService() {

    private lateinit var coordinator: InterceptionCoordinator

    override fun onServiceConnected() {
        super.onServiceConnected()
        coordinator = InterceptionCoordinator(applicationContext)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val packageName = event.packageName?.toString() ?: return
        // Ignore our own app to prevent loops
        if (packageName == "com.jeda.app") return
        // Ignore system UI
        if (packageName == "com.android.systemui") return
        if (packageName == "android") return

        if (coordinator.shouldIntercept(packageName)) {
            coordinator.recordIntercept(packageName)
            launchInterstitial(packageName)
        }
    }

    override fun onInterrupt() {
        // Required by interface — no-op
    }

    private fun launchInterstitial(packageName: String) {
        val intent = Intent(this, InterstitialActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(InterstitialActivity.EXTRA_PACKAGE_NAME, packageName)
        }
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
