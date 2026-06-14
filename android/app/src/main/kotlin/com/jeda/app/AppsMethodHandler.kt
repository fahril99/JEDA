package com.jeda.app

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

class AppsMethodHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) {
    private val scope = CoroutineScope(Dispatchers.Main)

    init {
        MethodChannel(messenger, "com.jeda.app/apps").setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    scope.launch {
                        val apps = withContext(Dispatchers.IO) { getInstalledApps() }
                        result.success(apps)
                    }
                }
                "getAppInfo" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    scope.launch {
                        val info = withContext(Dispatchers.IO) { getAppInfo(packageName) }
                        result.success(info)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = context.packageManager
        val intent = android.content.Intent(android.content.Intent.ACTION_MAIN, null).apply {
            addCategory(android.content.Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = pm.queryIntentActivities(intent, PackageManager.GET_META_DATA)
        return resolveInfos
            .mapNotNull { info ->
                try {
                    val appInfo = info.activityInfo.applicationInfo
                    val packageName = appInfo.packageName
                    if (packageName == "com.jeda.app") return@mapNotNull null

                    val label = pm.getApplicationLabel(appInfo).toString()
                    val icon = pm.getApplicationIcon(packageName)
                    val iconBase64 = drawableToBase64(icon)

                    mapOf(
                        "packageName" to packageName,
                        "appName" to label,
                        "icon" to iconBase64,
                    )
                } catch (_: Exception) { null }
            }
            .sortedBy { (it["appName"] as? String)?.lowercase() }
    }

    private fun getAppInfo(packageName: String): Map<String, Any?>? {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            val label = pm.getApplicationLabel(appInfo).toString()
            val icon = pm.getApplicationIcon(packageName)
            mapOf(
                "packageName" to packageName,
                "appName" to label,
                "icon" to drawableToBase64(icon),
            )
        } catch (_: Exception) { null }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = when (drawable) {
            is BitmapDrawable -> drawable.bitmap
            else -> {
                val bmp = Bitmap.createBitmap(
                    drawable.intrinsicWidth.coerceAtLeast(1),
                    drawable.intrinsicHeight.coerceAtLeast(1),
                    Bitmap.Config.ARGB_8888
                )
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
        }
        val scaled = Bitmap.createScaledBitmap(bitmap, 80, 80, true)
        val stream = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.PNG, 85, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }
}
