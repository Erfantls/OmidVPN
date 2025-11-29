package com.pira.omid

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import id.laskarmedia.openvpn_flutter.OpenVPNFlutterPlugin

class VpnNotificationService : Service() {
    companion object {
        const val CHANNEL_ID = "VpnNotificationChannel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_DISCONNECT = "DISCONNECT_VPN"
        
        private var isRunning = false
        
        fun startService(context: Context, serverName: String) {
            if (isRunning) return
            
            val intent = Intent(context, VpnNotificationService::class.java).apply {
                putExtra("serverName", serverName)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun stopService(context: Context) {
            isRunning = false
            context.stopService(Intent(context, VpnNotificationService::class.java))
        }
    }
    
    private var serverName: String = ""
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isRunning = true
        serverName = intent?.getStringExtra("serverName") ?: "Unknown Server"
        
        // Handle disconnect action
        if (intent?.action == ACTION_DISCONNECT) {
            disconnectVpn()
            return START_NOT_STICKY
        }
        
        startForeground(NOTIFICATION_ID, createNotification())
        return START_STICKY
    }
    
    private fun createNotification(): Notification {
        // Create disconnect intent
        val disconnectIntent = Intent(this, VpnNotificationService::class.java).apply {
            action = ACTION_DISCONNECT
        }
        
        val disconnectPendingIntent = PendingIntent.getService(
            this,
            0,
            disconnectIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )
        
        // Create open app intent
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val openAppPendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("VPN Connected")
            .setContentText("Connected to $serverName")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(openAppPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Disconnect", disconnectPendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Connection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows VPN connection status"
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun disconnectVpn() {
        try {
            // Send broadcast to disconnect VPN
            val disconnectIntent = Intent("vpn_disconnect_action")
            sendBroadcast(disconnectIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        // Stop the service
        stopSelf()
        isRunning = false
    }
    
    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
    }
}