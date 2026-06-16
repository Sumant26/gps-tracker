import Flutter
import UIKit

private let kChannelName = "battery_channel"

/**
 * Handles one-shot battery level reads from Flutter via `MethodChannel`.
 *
 * Uses `UIDevice.current.batteryLevel` — no third-party battery packages are used.
 */
class BatteryChannelHandler: NSObject, FlutterStreamHandler {

    private let channel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: kChannelName, binaryMessenger: messenger)
        super.init()
        channel.setMethodCallHandler(handle(_:result:))

        // Must enable battery monitoring before reading level.
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    // MARK: - MethodCallHandler

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getBatteryLevel":
            result(batteryLevel())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Battery Reading

    /**
     * Returns the current battery level as an integer percentage (0–100).
     * Returns -1 if the level cannot be determined.
     */
    private func batteryLevel() -> Int {
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return -1 }
        return Int(level * 100)
    }

    // MARK: - FlutterStreamHandler (unused here)

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { nil }
    func onCancel(withArguments arguments: Any?) -> FlutterError? { nil }
}
