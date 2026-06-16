package com.gps.tracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*

private const val TAG = "TrackingForegroundService"
private const val NOTIFICATION_ID = 1001
private const val CHANNEL_ID = "gps_tracking_channel"
private const val LOCATION_INTERVAL_MS = 60_000L

/**
 * Foreground service that captures GPS coordinates every 60 seconds.
 *
 * Configured as START_STICKY so the OS automatically restarts it
 * if the process is killed (e.g. when swiped from recents).
 * A persistent notification is shown as required by Android foreground
 * service rules.
 */
class TrackingForegroundService : Service() {

    companion object {
        const val ACTION_START       = "com.gps.tracker.START"
        const val ACTION_STOP        = "com.gps.tracker.STOP"
        const val EXTRA_SESSION_ID   = "session_id"
    }

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var sessionId: String? = null

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()
        buildLocationCallback()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                sessionId = intent.getStringExtra(EXTRA_SESSION_ID)
                Log.i(TAG, "Starting tracking for session $sessionId")
                startForeground(NOTIFICATION_ID, buildNotification())
                requestLocationUpdates()
            }
            ACTION_STOP -> {
                Log.i(TAG, "Stopping tracking for session $sessionId")
                stopLocationUpdates()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        // START_STICKY: OS will restart this service with a null intent after it is killed.
        return START_STICKY
    }

    private fun requestLocationUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            LOCATION_INTERVAL_MS
        )
            .setMinUpdateIntervalMillis(LOCATION_INTERVAL_MS)
            .build()

        try {
            fusedLocationClient.requestLocationUpdates(
                request,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Location permission not granted: ${e.message}")
        }
    }

    private fun stopLocationUpdates() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun buildLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                result.lastLocation?.let { location ->
                    Log.d(TAG, "Location: ${location.latitude}, ${location.longitude}")
                    broadcastLocation(location)
                }
            }
        }
    }

    /**
     * Broadcasts the captured location via a local broadcast so that
     * [LocationReceiver] can forward it to the Flutter layer.
     */
    private fun broadcastLocation(location: Location) {
        val intent = Intent(LocationReceiver.ACTION_LOCATION_UPDATE).apply {
            putExtra(LocationReceiver.EXTRA_SESSION_ID,  sessionId)
            putExtra(LocationReceiver.EXTRA_LATITUDE,    location.latitude)
            putExtra(LocationReceiver.EXTRA_LONGITUDE,   location.longitude)
            putExtra(LocationReceiver.EXTRA_ACCURACY,    location.accuracy)
            putExtra(LocationReceiver.EXTRA_TIMESTAMP,   System.currentTimeMillis())
        }
        sendBroadcast(intent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "GPS Tracking",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Active GPS tracking session"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("GPS Tracker Active")
            .setContentText("Recording your location in the background.")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
