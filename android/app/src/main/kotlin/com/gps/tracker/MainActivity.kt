package com.gps.tracker

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Main activity — wires up platform channel handlers and
 * starts the tracking foreground service when needed.
 */
class MainActivity : FlutterActivity() {

    private lateinit var batteryChannelHandler: BatteryChannelHandler
    private lateinit var batteryEventHandler: BatteryEventHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        batteryChannelHandler = BatteryChannelHandler(this, flutterEngine.dartExecutor.binaryMessenger)
        batteryEventHandler   = BatteryEventHandler(this, flutterEngine.dartExecutor.binaryMessenger)

        batteryChannelHandler.register()
        batteryEventHandler.register()
    }

    /** Starts the GPS foreground service. Called from Flutter via MethodChannel if needed. */
    fun startTrackingService(sessionId: String) {
        val intent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_START
            putExtra(TrackingForegroundService.EXTRA_SESSION_ID, sessionId)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    /** Stops the GPS foreground service. */
    fun stopTrackingService() {
        val intent = Intent(this, TrackingForegroundService::class.java).apply {
            action = TrackingForegroundService.ACTION_STOP
        }
        startService(intent)
    }

    override fun onDestroy() {
        batteryEventHandler.unregister()
        super.onDestroy()
    }
}
