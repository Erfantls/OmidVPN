package com.pira.omid

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import androidx.core.graphics.drawable.toBitmap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.nio.charset.StandardCharsets

class AppListMethodChannel(private val context: Context) : MethodCallHandler {
    companion object {
        const val CHANNEL = "com.pira.omid/app_list"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(AppListMethodChannel(context))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstalledApps" -> {
                // Run the operation in a background thread to avoid blocking the UI
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val packageManager = context.packageManager
                        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                        
                        val appList = mutableListOf<Map<String, Any>>()
                        
                        for (appInfo in installedApps) {
                            // More inclusive approach to show all user apps and launcher apps
                            // This should fix the issue with apps like Snapp not appearing
                            val launchIntent = packageManager.getLaunchIntentForPackage(appInfo.packageName)
                            val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                            val isUpdatedSystemApp = (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
                            
                            // Include the app if:
                            // 1. It has a launcher intent (typical user app)
                            // 2. It's not a system app (user installed app)
                            // 3. It's an updated system app (user updated a system app)
                            // This broader criteria should include apps like Snapp
                            if (launchIntent != null || !isSystemApp || isUpdatedSystemApp) {
                                // Get app name with proper UTF-8 encoding support
                                val appName = packageManager.getApplicationLabel(appInfo).toString()
                                
                                // Ensure proper encoding for Persian/Arabic characters
                                val encodedAppName = String(appName.toByteArray(StandardCharsets.UTF_8), StandardCharsets.UTF_8)
                                
                                val packageName = appInfo.packageName
                                
                                // Get app icon as base64 string
                                var iconBase64 = ""
                                try {
                                    val appIcon = packageManager.getApplicationIcon(appInfo.packageName)
                                    iconBase64 = drawableToBase64(appIcon)
                                } catch (e: Exception) {
                                    // If we can't get the icon, we'll just leave it empty
                                    iconBase64 = ""
                                }
                                
                                appList.add(mapOf(
                                    "name" to encodedAppName,
                                    "packageName" to packageName,
                                    "isSystemApp" to isSystemApp,
                                    "icon" to iconBase64
                                ))
                            }
                        }
                        
                        // Sort by app name with UTF-8 support
                        val sortedAppList = appList.sortedWith(compareBy({ 
                            (it["name"] as? String)?.lowercase()?.let { name ->
                                String(name.toByteArray(StandardCharsets.UTF_8), StandardCharsets.UTF_8)
                            } ?: ""
                        }))
                        
                        // Return result on the main thread
                        withContext(Dispatchers.Main) {
                            result.success(sortedAppList)
                        }
                    } catch (e: Exception) {
                        // Return error on the main thread
                        withContext(Dispatchers.Main) {
                            result.error("APP_LIST_ERROR", "Failed to get installed apps: ${e.message}", e.toString())
                        }
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun drawableToBase64(drawable: Drawable): String {
        // Convert drawable to bitmap
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            drawable.toBitmap(96, 96, Bitmap.Config.ARGB_8888)
        }
        
        // Compress bitmap to byte array
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        
        // Convert byte array to base64 string
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }
}