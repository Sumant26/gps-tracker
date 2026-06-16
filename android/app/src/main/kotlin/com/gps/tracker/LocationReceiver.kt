package com.gps.tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

private const val TAG = "LocationReceiver"

/**
 * Receives location broadcasts from [TrackingForegroundService] and
 * can forward them to the Flutter layer via an EventChannel if needed.
 *
 * In this architecture the Flutter side polls Hive directly; this receiver
 * is the integration point for any additional native-to-Flutter signalling.
 */
class LocationReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_LOCATION_UPDATE = "com.gps.tracker.LOCATION_UPDATE"
        const val EXTRA_SESSION_ID       = "session_id"
        const val EXTRA_LATITUDE         = "latitude"
        const val EXTRA_LONGITUDE        = "longitude"
        const val EXTRA_ACCURACY         = "accuracy"
        const val EXTRA_TIMESTAMP        = "timestamp"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_LOCATION_UPDATE) return

        val sessionId  = intent.getStringExtra(EXTRA_SESSION_ID)
        val latitude   = intent.getDoubleExtra(EXTRA_LATITUDE, 0.0)
        val longitude  = intent.getDoubleExtra(EXTRA_LONGITUDE, 0.0)
        val accuracy   = intent.getFloatExtra(EXTRA_ACCURACY, 0f)
        val timestamp  = intent.getLongExtra(EXTRA_TIMESTAMP, 0L)

        Log.d(TAG, "Received location for $sessionId: $latitude, $longitude ±${accuracy}m")

        // Future: forward to EventChannel sink for real-time Flutter updates.
    }
}
