package com.jeda.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Restores service state after device reboot or app update.
 * The AccessibilityService is managed by Android — we only need to
 * ensure coordinator state (SharedPrefs) persists, which it does automatically.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                // SharedPrefs persists across reboots.
                // Accessibility service will auto-start if user granted it.
                // No additional work needed.
            }
        }
    }
}
