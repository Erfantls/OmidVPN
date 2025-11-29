package com.pira.omid

import android.app.AlertDialog
import android.content.BroadcastReceiver
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import id.laskarmedia.openvpn_flutter.OpenVPNFlutterPlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpn_notification"
    private lateinit var disconnectReceiver: BroadcastReceiver
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startNotificationService" -> {
                    val serverName = call.argument<String>("serverName") ?: "Unknown Server"
                    VpnNotificationService.startService(this, serverName)
                    result.success(null)
                }
                "stopNotificationService" -> {
                    VpnNotificationService.stopService(this)
                    result.success(null)
                }
                "checkNotificationPermission" -> {
                    result.success(checkNotificationPermission())
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Register broadcast receiver for VPN disconnect
        disconnectReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == "vpn_disconnect_action") {
                    // Send a message back to Flutter to handle the disconnection
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("disconnectVpn", null)
                }
            }
        }
        
        val filter = IntentFilter("vpn_disconnect_action")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(disconnectReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(disconnectReceiver, filter)
        }
    }
    
    // Check if notification permission is granted
    private fun checkNotificationPermission(): Boolean {
        return NotificationManagerCompat.from(this).areNotificationsEnabled()
    }
    
    // Request notification permission
    private fun requestNotificationPermission() {
        if (!checkNotificationPermission()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                showNotificationPermissionDialog()
            } else {
                showNotificationPermissionDialog()
            }
        }
    }
    
    // Show dialog to request notification permission
    private fun showNotificationPermissionDialog() {
        AlertDialog.Builder(this)
            .setTitle("Notification Permission Required")
            .setMessage("This app needs notification permission to show VPN connection status. Please enable notifications in app settings.")
            .setPositiveButton("Open Settings") { _: DialogInterface, _: Int ->
                openAppSettings()
            }
            .setNegativeButton("Later", null)
            .show()
    }
    
    // Open app settings
    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", packageName, null)
        intent.data = uri
        startActivity(intent)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(disconnectReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        OpenVPNFlutterPlugin.connectWhileGranted(requestCode == 24 && resultCode == RESULT_OK)
        super.onActivityResult(requestCode, resultCode, data)
    }
}