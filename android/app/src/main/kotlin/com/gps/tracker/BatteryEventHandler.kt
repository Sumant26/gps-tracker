package com.gps.tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

private const val CHANNEL = "battery_event_channel"

/**
 * Streams real-time battery level changes to Flutter via [EventChannel].
 *
 * Registers a [BroadcastReceiver] for [Intent.ACTION_BATTERY_CHANGED]
 * and forwards the percentage each time it fires.
 * No third-party battery packages are used.
 */
class BatteryEventHandler(
    private val context: Context,
    messenger: BinaryMessenger
) : EventChannel.StreamHandler {

    private val channel = EventChannel(messenger, CHANNEL)
    private var receiver: BroadcastReceiver? = null

    /** Registers this handler on the event channel. */
    fun register() {
        channel.setStreamHandler(this)
    }

    /** Unregisters the broadcast receiver to prevent leaks. */
    fun unregister() {
        receiver?.let { context.unregisterReceiver(it) }
        receiver = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                if (level >= 0 && scale > 0) {
                    events.success(level * 100 / scale)
                }
            }
        }
        context.registerReceiver(
            receiver,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
    }

    override fun onCancel(arguments: Any?) {
        unregister()
    }
}
