package com.jeda.app

import android.content.Context
import android.content.SharedPreferences

/**
 * Manages the list of target packages, cooldown logic, and interception decisions.
 * Cooldown prevents repeated interstitials from the same app within a short window.
 */
class InterceptionCoordinator(private val context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences("jeda_prefs", Context.MODE_PRIVATE)

    companion object {
        const val KEY_TARGET_PACKAGES = "target_packages"
        const val KEY_SERVICE_ENABLED = "service_enabled"
        private const val COOLDOWN_MS = 10_000L // 10 seconds between interceptions of same app
    }

    private val recentIntercepts = mutableMapOf<String, Long>()

    fun shouldIntercept(packageName: String): Boolean {
        if (!isServiceEnabled()) return false
        val targets = getTargetPackages()
        if (!targets.contains(packageName)) return false

        val lastTime = recentIntercepts[packageName] ?: 0L
        val now = System.currentTimeMillis()
        return (now - lastTime) > COOLDOWN_MS
    }

    fun recordIntercept(packageName: String) {
        recentIntercepts[packageName] = System.currentTimeMillis()
    }

    fun getTargetPackages(): Set<String> {
        return prefs.getStringSet(KEY_TARGET_PACKAGES, emptySet()) ?: emptySet()
    }

    fun updateTargetPackages(packages: List<String>) {
        prefs.edit().putStringSet(KEY_TARGET_PACKAGES, packages.toSet()).apply()
    }

    fun isServiceEnabled(): Boolean {
        return prefs.getBoolean(KEY_SERVICE_ENABLED, true)
    }

    fun setServiceEnabled(enabled: Boolean) {
        prefs.edit().putBoolean(KEY_SERVICE_ENABLED, enabled).apply()
    }

    fun getDefaultCountdown(): Int {
        return prefs.getInt("default_countdown_sec", 5)
    }
}
